import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class ScoreCard extends StatelessWidget {
  final int score;
  final String label;
  final String description;
  final bool compact;

  const ScoreCard({
    super.key,
    required this.score,
    required this.label,
    required this.description,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gaugeSize = compact ? 60.0 : 80.0;
    final fontSize = compact ? 10.0 : 12.0;

    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: Colors.black26,
        clipBehavior: Clip.hardEdge,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF009688)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: gaugeSize,
                  width: gaugeSize,
                  child: SfRadialGauge(
                    axes: [
                      RadialAxis(
                        minimum: 0,
                        maximum: 100,
                        showLabels: false,
                        showTicks: false,
                        startAngle: 270,
                        endAngle: 270,
                        radiusFactor: 0.8,
                        axisLineStyle: AxisLineStyle(
                          thickness: 0.1,
                          thicknessUnit: GaugeSizeUnit.factor,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        pointers: [
                          RangePointer(
                            value: score.toDouble(),
                            width: 0.2,
                            sizeUnit: GaugeSizeUnit.factor,
                            color: Colors.white,
                            enableAnimation: true,
                            animationDuration: 1200,
                            animationType: AnimationType.ease,
                          ),
                        ],
                        annotations: [
                          GaugeAnnotation(
                            widget: Text(
                              '$score%',
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            angle: 90,
                            positionFactor: 0.45,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: fontSize - 2,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
