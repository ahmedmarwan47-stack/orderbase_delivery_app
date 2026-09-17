import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_tab_bar/liquid_tab_bar.dart';
import 'package:liquid_tab_bar/src/test_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LiquidTabBarController Lifecycle & State', () {
    test('initial state defaults', () {
      final controller = LiquidTabBarController();
      expect(controller.minimized, isFalse);
      expect(controller.material, equals(LiquidTabBarMaterial.auto));
      expect(controller.isDisposed, isFalse);
      controller.dispose();
      expect(controller.isDisposed, isTrue);
    });

    test('minimize and expand notify listeners and toggle minimized', () {
      final controller = LiquidTabBarController();
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.minimize();
      expect(controller.minimized, isTrue);
      expect(notifyCount, 1);

      // Repeated minimize does not notify
      controller.minimize();
      expect(notifyCount, 1);

      controller.expand();
      expect(controller.minimized, isFalse);
      expect(notifyCount, 2);

      // Repeated expand does not notify
      controller.expand();
      expect(notifyCount, 2);

      controller.dispose();
    });

    test('disposed controller does not notify or crash on calls', () {
      final controller = LiquidTabBarController();
      controller.dispose();

      expect(controller.isDisposed, isTrue);

      // Calling minimize or expand after dispose must not throw
      controller.minimize();
      controller.expand();
      controller.armGovernor();
      controller.resetGovernor();
    });

    test(
      'material changes update effectiveMaterial and trigger notifications',
      () {
        final controller = LiquidTabBarController();
        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.material = LiquidTabBarMaterial.blur;
        expect(controller.material, equals(LiquidTabBarMaterial.blur));
        expect(controller.effectiveMaterial, equals(LiquidTabBarMaterial.blur));
        expect(notifyCount, 1);

        controller.material = LiquidTabBarMaterial.opaque;
        expect(controller.material, equals(LiquidTabBarMaterial.opaque));
        expect(
          controller.effectiveMaterial,
          equals(LiquidTabBarMaterial.opaque),
        );
        expect(notifyCount, 2);

        // Setting same material is a no-op
        controller.material = LiquidTabBarMaterial.opaque;
        expect(notifyCount, 2);

        controller.dispose();
      },
    );
  });

  group('LiquidTabBarController.handleScroll', () {
    testWidgets('ignores non-zero depth by default (nested scrollables)', (
      tester,
    ) async {
      await tester.pumpWidget(const SizedBox.shrink());
      final context = tester.element(find.byType(SizedBox));

      final controller = LiquidTabBarController();
      addTearDown(controller.dispose);

      final metrics = FixedScrollMetrics(
        minScrollExtent: 0,
        maxScrollExtent: 500,
        pixels: 50,
        viewportDimension: 300,
        axisDirection: AxisDirection.down,
        devicePixelRatio: 1.0,
      );

      final nestedNotification = ScrollUpdateNotification(
        context: context,
        metrics: metrics,
        scrollDelta: 20,
        depth: 1, // Nested scrollable
      );

      final handled = controller.handleScroll(nestedNotification);
      expect(handled, isFalse);
      expect(controller.minimized, isFalse);
    });

    testWidgets('accepts non-zero depth when allowNested is true', (
      tester,
    ) async {
      await tester.pumpWidget(const SizedBox.shrink());
      final context = tester.element(find.byType(SizedBox));

      final controller = LiquidTabBarController();
      addTearDown(controller.dispose);

      final metrics = FixedScrollMetrics(
        minScrollExtent: 0,
        maxScrollExtent: 500,
        pixels: 50,
        viewportDimension: 300,
        axisDirection: AxisDirection.down,
        devicePixelRatio: 1.0,
      );

      final nestedNotification = ScrollUpdateNotification(
        context: context,
        metrics: metrics,
        scrollDelta: 20,
        depth: 1,
      );

      controller.handleScroll(nestedNotification, allowNested: true);
      expect(controller.minimized, isTrue);
    });

    testWidgets(
      'downward scroll past threshold minimizes, upward scroll expands',
      (tester) async {
        await tester.pumpWidget(const SizedBox.shrink());
        final context = tester.element(find.byType(SizedBox));

        final controller = LiquidTabBarController();
        addTearDown(controller.dispose);

        final metrics = FixedScrollMetrics(
          minScrollExtent: 0,
          maxScrollExtent: 500,
          pixels: 50,
          viewportDimension: 300,
          axisDirection: AxisDirection.down,
          devicePixelRatio: 1.0,
        );

        // Scroll down by 5px (below 12px threshold)
        controller.handleScroll(
          ScrollUpdateNotification(
            context: context,
            metrics: metrics,
            scrollDelta: 5,
          ),
        );
        expect(controller.minimized, isFalse);

        // Scroll down by another 10px (cumulative 15px > 12px threshold)
        controller.handleScroll(
          ScrollUpdateNotification(
            context: context,
            metrics: metrics,
            scrollDelta: 10,
          ),
        );
        expect(controller.minimized, isTrue);

        // Scroll up by 15px
        controller.handleScroll(
          ScrollUpdateNotification(
            context: context,
            metrics: metrics,
            scrollDelta: -15,
          ),
        );
        expect(controller.minimized, isFalse);
      },
    );

    testWidgets('reaching top (pixels <= 0) automatically expands', (
      tester,
    ) async {
      await tester.pumpWidget(const SizedBox.shrink());
      final context = tester.element(find.byType(SizedBox));

      final controller = LiquidTabBarController();
      addTearDown(controller.dispose);

      controller.minimize();
      expect(controller.minimized, isTrue);

      final topMetrics = FixedScrollMetrics(
        minScrollExtent: 0,
        maxScrollExtent: 500,
        pixels: 0,
        viewportDimension: 300,
        axisDirection: AxisDirection.down,
        devicePixelRatio: 1.0,
      );

      controller.handleScroll(
        ScrollUpdateNotification(context: context, metrics: topMetrics),
      );
      expect(controller.minimized, isFalse);
    });

    testWidgets('short page (maxScrollExtent < 120) is ignored', (
      tester,
    ) async {
      await tester.pumpWidget(const SizedBox.shrink());
      final context = tester.element(find.byType(SizedBox));

      final controller = LiquidTabBarController();
      addTearDown(controller.dispose);

      final shortMetrics = FixedScrollMetrics(
        minScrollExtent: 0,
        maxScrollExtent: 80,
        pixels: 20,
        viewportDimension: 300,
        axisDirection: AxisDirection.down,
        devicePixelRatio: 1.0,
      );

      controller.handleScroll(
        ScrollUpdateNotification(
          context: context,
          metrics: shortMetrics,
          scrollDelta: 30,
        ),
      );
      expect(controller.minimized, isFalse);
    });

    testWidgets('handleScroll does not minimize when shrinkOnScroll is false', (
      tester,
    ) async {
      await tester.pumpWidget(const SizedBox.shrink());
      final context = tester.element(find.byType(SizedBox));

      final controller = LiquidTabBarController(shrinkOnScroll: false);
      addTearDown(controller.dispose);

      final metrics = FixedScrollMetrics(
        minScrollExtent: 0,
        maxScrollExtent: 500,
        pixels: 50,
        viewportDimension: 300,
        axisDirection: AxisDirection.down,
        devicePixelRatio: 1.0,
      );

      controller.handleScroll(
        ScrollUpdateNotification(
          context: context,
          metrics: metrics,
          scrollDelta: 50,
        ),
      );

      expect(controller.minimized, isFalse);

      controller.shrinkOnScroll = true;
      expect(controller.shrinkOnScroll, isTrue);

      controller.handleScroll(
        ScrollUpdateNotification(
          context: context,
          metrics: metrics,
          scrollDelta: 50,
        ),
      );

      expect(controller.minimized, isTrue);
    });

    testWidgets(
      'handleScroll deduplicates identical notifications and clears on ScrollEndNotification',
      (tester) async {
        await tester.pumpWidget(const SizedBox.shrink());
        final context = tester.element(find.byType(SizedBox));

        final controller = LiquidTabBarController();
        addTearDown(controller.dispose);

        final metrics = FixedScrollMetrics(
          minScrollExtent: 0,
          maxScrollExtent: 500,
          pixels: 50,
          viewportDimension: 300,
          axisDirection: AxisDirection.down,
          devicePixelRatio: 1.0,
        );

        final update = ScrollUpdateNotification(
          context: context,
          metrics: metrics,
          scrollDelta: 5,
        );

        // First call processes travel
        controller.handleScroll(update);
        // Second call with identical notification is a deduplicated no-op
        controller.handleScroll(update);

        // ScrollEndNotification clears retained notification reference
        final end = ScrollEndNotification(context: context, metrics: metrics);
        controller.handleScroll(end);

        // New update can now be processed cleanly without retaining old notification
        final update2 = ScrollUpdateNotification(
          context: context,
          metrics: metrics,
          scrollDelta: 50,
        );
        controller.handleScroll(update2);
        expect(controller.minimized, isTrue);
      },
    );
  });

  group('LiquidTabBarController Frame Governor & Degradation', () {
    setUp(() {
      LiquidGlassTestOverrides.forceSupported = true;
    });

    tearDown(() {
      LiquidGlassTestOverrides.forceSupported = false;
    });

    FrameTiming makeTiming({required int rasterDurationMs}) {
      final finish = 3000 + rasterDurationMs * 1000;
      return FrameTiming(
        vsyncStart: 0,
        buildStart: 1000,
        buildFinish: 3000,
        rasterStart: 3000,
        rasterFinish: finish,
        rasterFinishWallTime: finish,
      );
    }

    test('isGovernorArmed tracks armGovernor() and dispose()', () {
      final controller = LiquidTabBarController();
      expect(controller.isGovernorArmed, isFalse);

      controller.armGovernor();
      expect(controller.isGovernorArmed, isTrue);

      controller.dispose();
      expect(controller.isGovernorArmed, isFalse);
    });

    test('warmup period (first 90 frames) ignores slow frames', () {
      final controller = LiquidTabBarController();
      addTearDown(controller.dispose);
      controller.armGovernor();

      final slow = makeTiming(rasterDurationMs: 30); // 30ms > 24ms threshold
      // Feed 90 slow frames during warmup
      for (int i = 0; i < 90; i++) {
        controller.onTimings([slow]);
      }

      expect(controller.isDegraded, isFalse);
      expect(controller.effectiveMaterial, equals(LiquidTabBarMaterial.glass));
    });

    test(
      'fewer than 12 slow frames in a 60-frame window does not degrade tier',
      () {
        final controller = LiquidTabBarController();
        addTearDown(controller.dispose);
        controller.armGovernor();

        final fast = makeTiming(rasterDurationMs: 8);
        final slow = makeTiming(rasterDurationMs: 30);

        // Warmup: 90 frames
        for (int i = 0; i < 90; i++) {
          controller.onTimings([fast]);
        }

        // 50 fast frames + 10 slow frames = 60 frames, 10 slow < 12
        for (int i = 0; i < 50; i++) {
          controller.onTimings([fast]);
        }
        for (int i = 0; i < 10; i++) {
          controller.onTimings([slow]);
        }

        expect(controller.isDegraded, isFalse);
        expect(
          controller.effectiveMaterial,
          equals(LiquidTabBarMaterial.glass),
        );
      },
    );

    test(
      '12 slow frames in a 60-frame window degrades tier to blur and notifies',
      () {
        final controller = LiquidTabBarController();
        addTearDown(controller.dispose);
        controller.armGovernor();

        final fast = makeTiming(rasterDurationMs: 8);
        final slow = makeTiming(rasterDurationMs: 30);

        // Warmup: 90 frames
        for (int i = 0; i < 90; i++) {
          controller.onTimings([fast]);
        }

        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        // 12 slow frames
        for (int i = 0; i < 12; i++) {
          controller.onTimings([slow]);
        }
        // 48 fast frames = total 60 frames
        for (int i = 0; i < 48; i++) {
          controller.onTimings([fast]);
        }

        expect(controller.isDegraded, isTrue);
        expect(notifyCount, 1);
        expect(controller.effectiveMaterial, equals(LiquidTabBarMaterial.blur));

        // Resetting governor restores glass tier
        controller.resetGovernor();
        expect(controller.isDegraded, isFalse);
        expect(notifyCount, 2);
        expect(
          controller.effectiveMaterial,
          equals(LiquidTabBarMaterial.glass),
        );
      },
    );

    test(
        'governor degrades immediately when maxSlowFrames threshold is reached without waiting for window end',
        () {
      final controller = LiquidTabBarController();
      addTearDown(controller.dispose);
      controller.armGovernor();

      final fast = makeTiming(rasterDurationMs: 8);
      final slow = makeTiming(rasterDurationMs: 30);

      // Warmup: 90 frames
      for (int i = 0; i < 90; i++) {
        controller.onTimings([fast]);
      }

      // Feed exactly 12 slow frames (maxSlowFrames) without completing the 60-frame window
      for (int i = 0; i < 12; i++) {
        controller.onTimings([slow]);
      }

      // Must degrade immediately on frame 12 rather than waiting for 60 frames
      expect(controller.isDegraded, isTrue);
      expect(controller.effectiveMaterial, equals(LiquidTabBarMaterial.blur));

      // Reset governor: must zero all counters and require new warmup before degrading again
      controller.resetGovernor();
      expect(controller.isDegraded, isFalse);
      expect(controller.effectiveMaterial, equals(LiquidTabBarMaterial.glass));

      // Feeding 1 slow frame must NOT degrade because warmup has been reset
      controller.onTimings([slow]);
      expect(controller.isDegraded, isFalse);

      // Complete full warmup
      for (int i = 0; i < 89; i++) {
        controller.onTimings([fast]);
      }
      // Still not degraded
      expect(controller.isDegraded, isFalse);

      // Now feed 12 slow frames in the new window
      for (int i = 0; i < 12; i++) {
        controller.onTimings([slow]);
      }
      expect(controller.isDegraded, isTrue);
    });

    test('disposed controller ignores frame timings', () {
      final controller = LiquidTabBarController();
      controller.dispose();

      final slow = makeTiming(rasterDurationMs: 35);
      for (int i = 0; i < 200; i++) {
        controller.onTimings([slow]);
      }

      expect(controller.isDegraded, isFalse);
    });

    test('custom LiquidGovernorConfig thresholds are respected', () {
      final customConfig = LiquidGovernorConfig(
        warmupFrames: 5,
        windowFrames: 10,
        rasterThresholdMs: 16, // lower threshold (e.g. 60fps target)
        maxSlowFrames: 3,
      );
      final controller = LiquidTabBarController(governorConfig: customConfig);
      addTearDown(controller.dispose);
      controller.armGovernor();

      final fast = makeTiming(rasterDurationMs: 8);
      final slow = makeTiming(rasterDurationMs: 18); // > 16ms

      // Warmup: 5 frames
      for (int i = 0; i < 5; i++) {
        controller.onTimings([fast]);
      }

      // 3 slow frames in 10 frame window
      for (int i = 0; i < 3; i++) {
        controller.onTimings([slow]);
      }
      for (int i = 0; i < 7; i++) {
        controller.onTimings([fast]);
      }

      expect(controller.isDegraded, isTrue);
      expect(controller.effectiveMaterial, equals(LiquidTabBarMaterial.blur));
    });
  });
}
