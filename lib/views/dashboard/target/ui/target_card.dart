import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patients/models/target_model.dart';

class TargetCard extends StatelessWidget {
  final Target target;

  const TargetCard({super.key, required this.target});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              if (target.description.isNotEmpty) ...[
                Text(
                  target.description,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],
              _buildProgressBar(),
              const SizedBox(height: 8),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: target.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(target.icon, color: target.color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      target.title,
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: 2),
              Text('${target.currentValue.toStringAsFixed(0)}/${target.targetValue} ${target.unit}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String statusText;

    switch (target.status) {
      case 'Completed':
        badgeColor = const Color(0xFF4CAF50);
        statusText = 'Completed';
        break;
      case 'Expired':
        badgeColor = Colors.grey.shade500;
        statusText = 'Expired';
        break;
      case 'Paused':
        badgeColor = Colors.orange;
        statusText = 'Paused';
        break;
      default:
        if (target.isOnTrack) {
          badgeColor = const Color(0xFF4CAF50);
          statusText = 'On Track';
        } else if (target.isBehind) {
          badgeColor = const Color(0xFFF44336);
          statusText = 'Behind';
        } else {
          badgeColor = Colors.blue.shade500;
          statusText = 'In Progress';
        }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(
        statusText,
        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: badgeColor),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${target.progressPercentage}%',
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: target.color),
            ),
            Text('${target.remainingDays} days left', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: target.progress, backgroundColor: Colors.grey.shade200, color: target.color, minHeight: 4),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(_formatDate(target.endDate), style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600)),
          ],
        ),
        Row(
          children: [
            if (target.streak > 0) ...[
              Icon(Icons.local_fire_department, size: 12, color: Colors.orange.shade500),
              const SizedBox(width: 4),
              Text('${target.streak} days', style: GoogleFonts.poppins(fontSize: 10, color: Colors.orange.shade600)),
              const SizedBox(width: 12),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: Text(
                target.frequency,
                style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w';
    } else {
      return '${(difference.inDays / 30).floor()}m';
    }
  }
}
