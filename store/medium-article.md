# My Flutter App Bundle Was 222 MB. I Never Chose to Ship Most of It.

I shipped my first Android app to the Play Store last week.

It's called **Trapster**, and it teaches chess opening traps — the short, sharp lines that win games in the first ten moves. The Fried Liver. Légal's Mate. The Danish Gambit. Every trap comes with the *idea* behind each move rather than a move list to memorise, and there are two ways to drill it: Practice Mode, where you play the trap yourself move by move, and Avoid-the-Trap Mode, where the trap is set for **you** and you have to find the escape. There's a tunable Stockfish opponent, engine analysis with an evaluation bar, and the whole thing runs with no internet connection and no account.

> **[SCREENSHOT: the board in Practice Mode, mid-trap]**

That last part — fully offline — is the design decision that made this article necessary. Because somewhere between "it builds" and "it's live", I ran `flutter build appbundle --release` and watched this scroll past:

```
√ Built build/app/outputs/bundle/release/app-release.aab (221.9MB)
```

Two hundred and twenty-two megabytes. For an app whose entire job is showing a chessboard.

My first instinct was that I'd broken something. My second was to panic about Google Play's 200 MB limit. Both were wrong, and finding out why taught me more about Android app bundles than any tutorial had.

Here's what I found, and how you can run the same audit on your own app in about ten minutes.

---

## The number you see is not the number that matters

Google Play's size limit is on **compressed download size** — what a single device actually pulls down. The `.aab` file on your disk is a different thing entirely. It's a container holding every architecture, every screen density, every language, plus metadata that never reaches a phone.

Play Console eventually told me the real figure: **81.2 MB install size**. So where did the other 140 MB go?

An `.aab` is just a zip. You can look inside:

```bash
unzip -lv app-release.aab | awk '$1 ~ /^[0-9]+$/ && NF>=8 {
  c=$3; p=$8; n=split(p,q,"/");
  k=(p ~ /^base\/lib\//) ? "base/lib/"q[3] : q[1]"/"q[2];
  agg[k]+=c
} END { for (k in agg) printf "%8.2f MB  %s\n", agg[k]/1048576, k }' | sort -rn
```

Note `$3`, not `$1` — the first column is the *uncompressed* size, which is the mistake I made on my first pass and which made everything look twice as bad as it was.

My result:

```
   93.50 MB  BUNDLE-METADATA/com.android.tools.build.debugsymbols
   44.90 MB  base/lib/arm64-v8a
   44.60 MB  base/lib/armeabi-v7a
   27.50 MB  base/assets
    4.90 MB  BUNDLE-METADATA/com.android.tools.build.obfuscation
    4.10 MB  base/dex
    1.30 MB  base/res
```

Two things jump out.

**`BUNDLE-METADATA` is 98 MB and never ships.** Those are native debug symbols and your ProGuard mapping file. Play keeps them so it can symbolicate your crash reports. They inflate the upload and nothing else. Nearly half my "222 MB app" was crash-reporting metadata.

**The two `lib/` folders are alternatives, not additions.** An arm64 phone gets the 44.9 MB folder. A 32-bit phone gets the other one. Nobody gets both.

Real payload for an arm64 device: 44.9 + 27.5 + 4.1 + 1.3 ≈ **78 MiB**, which is the 81.2 MB Play reported once you convert MiB to the decimal MB the console uses. The mystery evaporated.

If you take one thing from this article: **stop reading the number `flutter build` prints.** It is not the number your users experience, and panicking about it will send you optimizing the wrong things.

---

## Then I looked at what actually ships

Fine — 81 MB, not 222. But 81 MB is still a lot for a chessboard. So I broke down the parts that do reach a device.

Native libraries first:

| Library | Compressed | Purpose |
|---|---|---|
| `libmultistockfish_sf16.so` | 32.98 MB | Stockfish 16 with embedded NNUE |
| `libflutter.so` | 5.16 MB | Flutter engine |
| `libapp.so` | 4.39 MB | My Dart code, AOT-compiled |
| `librive_text.so` | 1.27 MB | ??? |
| `libmultistockfish_variant.so` | 0.62 MB | Stockfish variant build |
| `libmultistockfish_chess.so` | 0.50 MB | Stockfish without NNUE |

Stockfish being 41% of my app is *fine*. That's the embedded neural network that lets Trapster analyse a position, drive a tunable opponent and show an evaluation bar on a phone in airplane mode. "Works offline, no account" is the promise on my store listing, and this is what that promise costs. It's a bill I chose to pay.

> **[SCREENSHOT: the evaluation bar and best-move hint during analysis]**

There is a cheaper Stockfish flavour — `latestNoNNUE` would drop that 32.98 MB to 0.50 MB — but it requires downloading the neural network at first launch. That would save more than every other optimization in this article combined, and I'm not doing it, because it trades the one feature people actually tell me they like for a smaller number in Play Console.

The other four lines are costs I never chose.

I ship one Stockfish flavour — the code calls `start()` with no arguments, which defaults to `sf16`. The other two binaries are never opened. And `librive_text.so`? I had no idea what Rive even was.

Then I looked at assets:

```
   24.17 MB  flutter_assets/packages/chessground
    2.53 MB  flutter_assets/assets          ← everything I actually authored
    0.35 MB  flutter_assets/packages/font_awesome_flutter
    0.24 MB  flutter_assets/packages/ionicons
```

A third of my app's install size was one dependency's assets. My own images, sounds and data came to 2.53 MB.

---

## 1,904 files for a feature I don't have

`chessground` is the Flutter board widget from Lichess. It's excellent. It also ships **40 piece sets** — alpha, cburnett, merida, maestro, fantasy, horsey and 34 more — each as 12 pieces across four screen densities. 1,904 image files, 22.12 MB compressed.

My app uses one. The default. There is no piece-set picker anywhere in my UI; `ChessboardSettings` never sets `pieceAssets`.

So every user downloads 39 piece sets they will never see, and stores them on their phone forever.

The board *themes* are a different story — I expose nine of them in Trapster's settings (brown, blue, green, wood, metal, marble, purple and two more), and those live in a separate 2.05 MB `boards/` folder that's entirely earned. But the pieces are pure dead weight.

> **[SCREENSHOT: the board theme picker showing several of the nine themes]**

The frustrating part: **Flutter gives you no way to exclude a dependency's assets.** Package assets are declared in the package's own pubspec and bundled wholesale. Your options are to fork the package and delete what you don't use, then point at it with a `dependency_override`, or to live with it. There's no flag, no allowlist, no tree-shaking for images.

I haven't done the fork yet. It's 90% of my remaining savings and also a maintenance commitment every time chessground releases — that's a trade I want to make deliberately, not the week I launch.

---

## The 16 KB error that came from a splash screen

Play Console flagged my release: *"Your app does not support 16 KB memory page sizes."* Android is moving to 16 KB pages, and native libraries have to be aligned for it.

You can check this yourself with the NDK's readelf. Extract the `.so` files and inspect the LOAD segment alignment:

```bash
unzip -o app-release.aab 'base/lib/arm64-v8a/*' -d ./extracted
llvm-readelf -lW ./extracted/base/lib/arm64-v8a/*.so | grep LOAD
```

You want `0x4000` (16 KB) or `0x10000` (64 KB). `0x1000` is 4 KB and it's the problem.

Seven of my eight libraries were fine. Stockfish was fine. Flutter was fine. The single offender was `librive_text.so` — the mystery library from earlier.

I don't use Rive. I have never imported it. There is not one `.riv` file in my project. It arrives like this:

```
splash_master 0.0.3 [flutter lottie video_player rive args xml yaml]
```

`splash_master` is a splash-screen package. Version 0.0.3 supported Rive, Lottie and video splash animations, and bundled **all three engines unconditionally** whether you used them or not. I use a static PNG.

So: a 4 KB-aligned native library, from an animation engine I never touched, pulled in by a package whose only job is to hold the splash screen for half a second, blocking a Play Store compliance check.

The fix was upgrading to `splash_master 1.0.0+1`, which split those into optional companion packages. Dependencies became `[flutter xml yaml]`. Rive, Lottie and video_player all vanished, and all seven remaining libraries came back 16 KB-clean.

**Check your transitive dependencies.** Run `flutter pub deps --style=compact` and actually read it. I would never have guessed that my splash screen was shipping a text-rendering engine.

---

## The ProGuard rules that were doing the opposite of their job

Play also suggested enabling R8 optimization. I had `isMinifyEnabled = true`, so R8 was already running. The problem was my rules:

```proguard
-keep class io.flutter.** { *; }
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.chessground.** { *; }
-keep class com.github.lichess.** { *; }
```

I'd copied these from a Stack Overflow answer years earlier, the way everyone does. Two observations.

The last two match nothing at all — chessground and dartchess are pure Dart. There has never been a `com.chessground` Java package for that rule to keep.

More importantly, AdMob and Firebase both ship their own `consumer-proguard-rules.pro` inside their AARs, keeping exactly what their reflection needs. My blanket rules weren't protecting them from anything. They were just telling R8 "don't touch these thousands of classes."

I deleted the Firebase and AdMob keeps, left `io.flutter.**` (the engine registers plugins reflectively) and the local-notifications package (it deserialises scheduled notifications by class name), and rebuilt.

Dex went from **4.10 MB to 3.37 MB**. An 18% reduction from deleting five lines.

If you do this, test on a release build. ProGuard problems don't reproduce in debug — that's the entire point of ProGuard — and a `ClassNotFoundException` in production is a bad way to learn you removed too much.

---

## What I'd tell you to do

Run the audit. It's ten minutes and you will find something.

1. Break the bundle down by compressed size and confirm what actually ships. Ignore the number `flutter build` prints.
2. Read your transitive dependency tree. The heaviest thing in your app is often something you never chose.
3. Check ELF alignment before Play tells you to.
4. Look at your ProGuard rules and ask which ones match a real class and which are cargo cult.

I got from 78.0 to 76.1 MiB with the easy fixes, which is honest but unspectacular. The remaining 21 MB sits behind forking a dependency, and I'll do it when I'm not shipping.

The real value wasn't the megabytes. It was going from "my app is 222 MB and I don't know why" to knowing exactly what every part of it is and whether I meant to put it there. That's a much better place to make decisions from.

---

## The app this came from

**Trapster** is a free chess trainer for Android. It teaches opening traps and gambits — the Fried Liver, Légal's Mate, the Danish Gambit, the Blackburne Shilling and a large hand-picked library besides — with the reasoning behind every move rather than a line to memorise.

- **Practice Mode** — play the trap yourself, move by move, with instant feedback
- **Avoid-the-Trap Mode** — train to escape when the trap is set for you
- **Engine analysis** — evaluation bar and best-move hints, powered by the Stockfish build that costs 41% of this article
- **Play** a tunable Stockfish opponent, or 1v1 pass-and-play on one device
- **Search** traps by name or by the moves currently on the board
- **Fully offline**, no account, free, and available in English, French, Spanish and Arabic

> **[SCREENSHOT: home screen or the trap library]**

It's also **open source under GPL-3.0** — partly by choice and partly by obligation, since Stockfish, chessground and dartchess are all GPL-3.0 themselves. Which means every number in this article is verifiable: clone it, build it, run the same commands, and check my work.

📱 **[Get Trapster on Google Play](https://play.google.com/store/apps/details?id=chesstraps.achrafcyber.com)**
💻 **[Source on GitHub](https://github.com/Achraf-cyber/chess_traps)**

If you build something with it — or find 20 MB I missed — I'd genuinely like to hear about it.
