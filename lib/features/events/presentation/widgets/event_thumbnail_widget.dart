import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/event_model.dart';
import '../../../../core/services/zm_api_service.dart';

/// Event thumbnail widget for hover display
/// Replicates original zmNinja's thumbnail functionality
class EventThumbnailWidget extends ConsumerWidget {
  final EventModel event;
  final Offset position;

  const EventThumbnailWidget({
    super.key,
    required this.event,
    required this.position,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiService = ref.watch(zmApiServiceProvider);
    
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 300,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey[300],
                ),
                child: Image.network(
                  _buildThumbnailUrl(apiService, event),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              
              SizedBox(height: 8),
              
              Text(
                'Event ${event.id}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                event.cameraName,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                _formatDateTime(event.startTime),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (event.notes?.isNotEmpty == true)
                Text(
                  event.notes!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildThumbnailUrl(ZmApiService api, EventModel event) {
    // For now, use a placeholder URL - this will be properly implemented
    // when the API service provides a public method to get the base URL
    return 'http://localhost/zm/index.php?view=image&fid=1&eid=${event.id}&width=400';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
