
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:quickpourmerchant/features/profile/presentation/widgets/stattic_item_widget.dart';


class ProfileStatisticsSection extends StatelessWidget {
  const ProfileStatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatisticWithDivider(
              const ProfileStatisticItem(
                icon: FontAwesomeIcons.dollarSign,
                label: "sales",
                count: "0",
              ),
            ),
            _buildStatisticWithDivider(
              const ProfileStatisticItem(
                icon: FontAwesomeIcons.solidThumbsUp,
                label: "Likes",
                count: "0",
              ),
            ),
            // _buildStatisticWithDivider(
            //   BlocBuilder<FavoritesBloc, FavoritesState>(
            //     builder: (context, state) {
            //       return ProfileStatisticItem(
            //         icon: Icons.favorite_rounded,
            //         label: "Favorites",
            //         count: state.favorites.items.length.toString(),
            //       );
            //     },
            //   ),
            // ),
            
            const ProfileStatisticItem(
              icon: Icons.star_rounded,
              label: "Reviews",
              count: "0",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticWithDivider(Widget statisticItem) {
    return Row(
      children: [
        statisticItem,
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: VerticalDivider(
            color: Colors.grey[300],
            thickness: 1.5,
          ),
        ),
      ],
    );
  }
}
