import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DetailLocationWidget extends StatelessWidget {
  final bool isInsideArea;
  final String address;
  final bool isLoading;
  final VoidCallback? onTapCloseBtn;
  final VoidCallback? onTapConfirmBtn;

  const DetailLocationWidget({
    Key? key,
    required this.isInsideArea,
    required this.address,
    required this.isLoading,
    this.onTapCloseBtn,
    this.onTapConfirmBtn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 20,
            offset: const Offset(0, -4),
          )
        ],
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Detail Location',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          if (!isLoading) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: onTapCloseBtn != null
                    ? ThemeData(useMaterial3: true)
                        .colorScheme
                        .inversePrimary
                        .withOpacity(0.4)
                    : Colors.redAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isInsideArea ? Icons.near_me : Icons.near_me_disabled,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address.isEmpty ? 'Select Your Address ...' : address,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: isInsideArea ? Colors.black : Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: onTapCloseBtn,
                  color: Colors.black,
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: onTapCloseBtn != null
                          ? ThemeData(useMaterial3: true)
                              .colorScheme
                              .inversePrimary
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onTapConfirmBtn,
                    child: const Text(
                      'Confirm Location',
                    ),
                  ),
                ),
              ],
            ),
          ] else
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              enabled: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    height: 42,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
