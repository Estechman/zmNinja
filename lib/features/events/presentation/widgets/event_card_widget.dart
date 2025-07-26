import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/models/event_model.dart';

/// Individual event card widget for list display
/// Shows event thumbnail, metadata, and action buttons
class EventCardWidget extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final VoidCallback? onDownload;

  const EventCardWidget({
    super.key,
    required this.event,
    this.onTap,
    this.onPlay,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event thumbnail
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Thumbnail image
                  if (event.thumbnailPath != null)
                    CachedNetworkImage(
                      imageUrl: event.thumbnailPath!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    )
                  else
                    Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.videocam,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),

                  // Play button overlay
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        iconSize: 32,
                        onPressed: onPlay,
                      ),
                    ),
                  ),

                  // Duration badge
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        event.durationString,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Recording indicator
                  if (event.isRecording)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fiber_manual_record, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Event details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event name and camera
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        event.cameraName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Timestamp and alarm info
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${event.startTime.hour.toString().padLeft(2, '0')}:'
                        '${event.startTime.minute.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      if (event.alarmFrames > 0) ...[
                        Icon(Icons.warning, size: 14, color: Colors.orange[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${event.alarmPercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Action buttons
                  Row(
                    children: [
                      // Alarm score
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getScoreColor(event.maxScore),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Score: ${event.maxScore.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Download button
                      IconButton(
                        icon: const Icon(Icons.download),
                        iconSize: 20,
                        onPressed: onDownload,
                        tooltip: 'Download',
                      ),

                      // Share button
                      IconButton(
                        icon: const Icon(Icons.share),
                        iconSize: 20,
                        onPressed: () {
                          // TODO: Implement share functionality
                        },
                        tooltip: 'Share',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get color based on alarm score
  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.red;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.yellow[700]!;
    return Colors.green;
  }
}
