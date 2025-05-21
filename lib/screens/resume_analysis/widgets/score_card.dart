import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class ScoreRadialCard extends StatelessWidget {
  final int score;
  final String label;
  final String description;
  final bool compact;

  const ScoreRadialCard({
    super.key,
    required this.score,
    required this.label,
    required this.description,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gaugeSize = compact ? 50.0 : 70.0;
    final fontSize = compact ? 8.0 : 10.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(2),
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
                    radiusFactor: 0.75,
                    axisLineStyle: const AxisLineStyle(
                      thickness: 0.1,
                      thicknessUnit: GaugeSizeUnit.factor,
                      color: Colors.grey,
                    ),
                    pointers: [
                      RangePointer(
                        value: score.toDouble(),
                        width: 0.2,
                        sizeUnit: GaugeSizeUnit.factor,
                        color: const Color(0xFF4CAF50),
                        enableAnimation: true,
                        animationDuration: 1000,
                      ),
                    ],
                    annotations: [
                      GaugeAnnotation(
                        widget: Text(
                          '$score%',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
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
            const SizedBox(height: 0.5),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 0.5),
            Text(
              description,
              style: TextStyle(
                fontSize: fontSize - 2,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
