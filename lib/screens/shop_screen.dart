import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopScreenView extends StatelessWidget {
  const ShopScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Header
            Center(
              child: Text(
                '⚔️ SHOP',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFDD835),
                  letterSpacing: 2,
                  shadows: const [
                    Shadow(color: Colors.black45, offset: Offset(0, 3), blurRadius: 4),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Customize your game experience',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white54,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Board Themes Section
            _buildSectionTitle('BOARD THEMES'),
            const SizedBox(height: 12),
            _buildShopGrid([
              _ShopItem('🌊', 'Ocean', '500', true),
              _ShopItem('🌌', 'Galaxy', '800', false),
              _ShopItem('🔥', 'Inferno', '1200', false),
              _ShopItem('🌿', 'Forest', '600', false),
            ]),
            const SizedBox(height: 28),

            // Player Markers Section
            _buildSectionTitle('PLAYER MARKERS'),
            const SizedBox(height: 12),
            _buildShopGrid([
              _ShopItem('⚡', 'Lightning', '300', true),
              _ShopItem('💎', 'Diamond', '1500', false),
              _ShopItem('🌟', 'Star', '700', false),
              _ShopItem('❄️', 'Frost', '900', false),
            ]),
            const SizedBox(height: 28),

            // Emote Packs Section
            _buildSectionTitle('EMOTE PACKS'),
            const SizedBox(height: 12),
            _buildShopGrid([
              _ShopItem('😎', 'Cool Pack', '400', true),
              _ShopItem('👻', 'Spooky', '600', false),
              _ShopItem('🎉', 'Party', '500', false),
              _ShopItem('🥷', 'Ninja', '1000', false),
            ]),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFDD835), Color(0xFFF5A623)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopGrid(List<_ShopItem> items) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: items.map((item) => _buildShopCard(item)).toList(),
    );
  }

  Widget _buildShopCard(_ShopItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.owned ? const Color(0x66FDD835) : const Color(0x26FFFFFF),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 30)),
              if (item.owned)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0x33FDD835),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'OWNED',
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFDD835),
                    ),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (!item.owned)
                Row(
                  children: [
                    const Text('💰', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      item.price,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFDD835),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShopItem {
  final String emoji;
  final String name;
  final String price;
  final bool owned;
  const _ShopItem(this.emoji, this.name, this.price, this.owned);
}
