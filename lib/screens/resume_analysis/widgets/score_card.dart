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
    final gaugeSize = compact ? 80.0 : 100.0;
    final fontSize = compact ? 14.0 : 16.0;

    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
        clipBehavior: Clip.hardEdge,
        child: Container(
          height: 220, // ✅ reduce height
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF009688)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
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
                        radiusFactor: 1,
                        axisLineStyle: AxisLineStyle(
                          thickness: 0.12,
                          thicknessUnit: GaugeSizeUnit.factor,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        pointers: [
                          RangePointer(
                            value: score.toDouble(),
                            width: 0.12,
                            sizeUnit: GaugeSizeUnit.factor,
                            color: Colors.white,
                            enableAnimation: true,
                            animationDuration: 1000,
                          ),
                        ],
                        annotations: [
                          GaugeAnnotation(
                            angle: 90,
                            positionFactor: 0.0, // ✅ perfectly center the text
                            widget: Text(
                              '$score%',
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
