import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class ShopScreenView extends StatefulWidget {
  final SharedPreferences? prefs;
  final VoidCallback onCoinsChanged;
  final int playerCoins;

  const ShopScreenView({
    super.key,
    required this.prefs,
    required this.onCoinsChanged,
    required this.playerCoins,
  });

  @override
  State<ShopScreenView> createState() => _ShopScreenViewState();
}

class _ShopScreenViewState extends State<ShopScreenView> {
  String _equippedSkinId = 'classic';
  List<String> _ownedSkinIds = ['classic'];

  @override
  void initState() {
    super.initState();
    _loadShopState();
  }

  void _loadShopState() {
    if (widget.prefs != null) {
      setState(() {
        _equippedSkinId = widget.prefs!.getString('equippedSkinId') ?? 'classic';
        _ownedSkinIds = widget.prefs!.getStringList('ownedSkinIds') ?? ['classic'];
      });
    }
  }

  void _equipSkin(String skinId) {
    VibrationHelper.vibrate(widget.prefs, type: 'selection');
    widget.prefs?.setString('equippedSkinId', skinId);
    setState(() {
      _equippedSkinId = skinId;
    });
    widget.onCoinsChanged();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Equipped skin: ${allSkins.firstWhere((s) => s.id == skinId).name}!'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF187BCD),
      ),
    );
  }

  void _buySkin(SkinItem skin) {
    if (widget.playerCoins < skin.price) {
      VibrationHelper.vibrate(widget.prefs, type: 'medium');
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF0A2540),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'INSUFFICIENT COINS',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w900,
              color: Colors.redAccent,
            ),
          ),
          content: Text(
            'You need ${skin.price - widget.playerCoins} more Gold Coins to unlock the ${skin.name} skin.\n\nPlay matches to earn more coins!',
            style: GoogleFonts.outfit(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'OK',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFDD835),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // Deduct coins and add to owned list
    VibrationHelper.vibrate(widget.prefs, type: 'heavy');
    final newCoins = widget.playerCoins - skin.price;
    final newOwned = List<String>.from(_ownedSkinIds)..add(skin.id);

    widget.prefs?.setInt('playerCoins', newCoins);
    widget.prefs?.setStringList('ownedSkinIds', newOwned);
    widget.prefs?.setString('equippedSkinId', skin.id);

    setState(() {
      _ownedSkinIds = newOwned;
      _equippedSkinId = skin.id;
    });

    widget.onCoinsChanged();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A2540),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'SKIN UNLOCKED! 🎉',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            color: const Color(0xFFFDD835),
          ),
        ),
        content: Text(
          'Congratulations! You have unlocked and equipped the ${skin.name} skin markers.',
          style: GoogleFonts.outfit(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'AWESOME',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFDD835),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPreviewModal(SkinItem skin) {
    VibrationHelper.vibrate(widget.prefs, type: 'selection');
    final isOwned = _ownedSkinIds.contains(skin.id);
    final isEquipped = _equippedSkinId == skin.id;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0F3A6B), Color(0xFF002040)],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0x33FDD835), width: 2),
                boxShadow: const [
                  BoxShadow(color: Color(0xD9000000), blurRadius: 20, offset: Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    '${skin.name.toUpperCase()} PREVIEW',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFDD835),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${skin.rarity.toUpperCase()} MARKERS',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white54,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mock Board Grid
                  Container(
                    width: 240,
                    height: 240,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0x26000000),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0x26FFFFFF)),
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, idx) {
                        // Demo win diagonal
                        final isWinning = (idx == 0 || idx == 4 || idx == 8);
                        String val = '';
                        if (idx == 0 || idx == 4 || idx == 8 || idx == 2) {
                          val = 'X';
                        } else if (idx == 1 || idx == 5) {
                          val = 'O';
                        }

                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isWinning
                                  ? [const Color(0xFFFDD835), const Color(0xFFD35400)]
                                  : [const Color(0x1AFFFFFF), const Color(0x2DFFFFFF)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isWinning ? Colors.white : const Color(0x26FFFFFF),
                              width: isWinning ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: val.isEmpty
                                ? const SizedBox.shrink()
                                : Text(
                                    val == 'X' ? skin.xMarker : skin.oMarker,
                                    style: GoogleFonts.outfit(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      shadows: [
                                        if (skin.id == 'neon') ...[
                                          Shadow(
                                            color: val == 'X' ? const Color(0xFFFF00FF) : const Color(0xFF00FFFF),
                                            blurRadius: 12,
                                          )
                                        ],
                                        const Shadow(color: Colors.black45, offset: Offset(0, 2), blurRadius: 3),
                                      ],
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Actions in Dialog
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            'CLOSE',
                            style: GoogleFonts.outfit(
                              color: Colors.white54,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _buildDialogActionButton(skin, isOwned, isEquipped, ctx),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDialogActionButton(SkinItem skin, bool isOwned, bool isEquipped, BuildContext dialogCtx) {
    if (isEquipped) {
      return Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0x33FDD835),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFDD835)),
        ),
        child: Text(
          'EQUIPPED',
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFFDD835),
          ),
        ),
      );
    }

    if (isOwned) {
      return ElevatedButton(
        onPressed: () {
          Navigator.pop(dialogCtx);
          _equipSkin(skin.id);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2ECC71),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size.fromHeight(44),
        ),
        child: Text(
          'EQUIP NOW',
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: () {
        Navigator.pop(dialogCtx);
        _buySkin(skin);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF187BCD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size.fromHeight(44),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('BUY 💰 ', style: TextStyle(fontSize: 14)),
          Text(
            '${skin.price}',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

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
            // Header Row (Title & Coins)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0x1AFFF176),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0x4DFFF176), width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💰', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.playerCoins}',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFEE58),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Unlock custom X / O markers themes',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 28),

            // Skins Section
            _buildSectionTitle('MARKER SKINS'),
            const SizedBox(height: 16),
            Column(
              children: allSkins.map((skin) => _buildSkinCard(skin)).toList(),
            ),
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

  Widget _buildSkinCard(SkinItem skin) {
    final isOwned = _ownedSkinIds.contains(skin.id);
    final isEquipped = _equippedSkinId == skin.id;

    Color rarityColor;
    Color rarityBg;
    List<Color> cardGradient;
    Color borderColor;

    switch (skin.rarity) {
      case 'Common':
        rarityColor = const Color(0xFFBDC3C7);
        rarityBg = const Color(0x1FBDC3C7);
        borderColor = const Color(0x33BDC3C7);
        cardGradient = [const Color(0x0DFFFFFF), const Color(0x1BFFFFFF)];
        break;
      case 'Rare':
        rarityColor = const Color(0xFF3498DB);
        rarityBg = const Color(0x1F3498DB);
        borderColor = const Color(0x4D3498DB);
        cardGradient = [const Color(0x0F3498DB), const Color(0x1B3498DB)];
        break;
      case 'Epic':
        rarityColor = const Color(0xFF9B59B6);
        rarityBg = const Color(0x1F9B59B6);
        borderColor = const Color(0x669B59B6);
        cardGradient = [const Color(0x0F9B59B6), const Color(0x1B9B59B6)];
        break;
      case 'Legendary':
      default:
        rarityColor = const Color(0xFFFDD835);
        rarityBg = const Color(0x26FDD835);
        borderColor = const Color(0x80FDD835);
        cardGradient = [const Color(0x1AFDD835), const Color(0x2EFDD835)];
        break;
    }

    if (isEquipped) {
      borderColor = const Color(0xFFFDD835);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: cardGradient,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: isEquipped ? 2.0 : 1.5,
        ),
        boxShadow: isEquipped
            ? [
                const BoxShadow(
                  color: Color(0x33FDD835),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ]
            : const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                )
              ],
      ),
      child: Row(
        children: [
          // Left Info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skin.name,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: rarityBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    skin.rarity.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: rarityColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Center Preview
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                '${skin.xMarker} / ${skin.oMarker}',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    if (skin.id == 'neon') ...[
                      const Shadow(
                        color: Color(0xFFFF00FF),
                        blurRadius: 10,
                      )
                    ],
                    const Shadow(color: Colors.black38, offset: Offset(0, 2), blurRadius: 4),
                  ],
                ),
              ),
            ),
          ),

          // Right Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Preview Eye Button
              IconButton(
                onPressed: () => _showPreviewModal(skin),
                icon: const Icon(Icons.remove_red_eye_rounded),
                color: Colors.white70,
                tooltip: 'Preview Skin',
              ),
              const SizedBox(width: 4),

              // Purchase/Equip Button
              _buildActionButton(skin, isOwned, isEquipped),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(SkinItem skin, bool isOwned, bool isEquipped) {
    if (isEquipped) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFDD835), Color(0xFFF5A623)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Text(
          'EQUIPPED',
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF4A2C0F),
          ),
        ),
      );
    }

    if (isOwned) {
      return ElevatedButton(
        onPressed: () => _equipSkin(skin.id),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          backgroundColor: const Color(0xFF2ECC71),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'EQUIP',
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: () => _buySkin(skin),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: const Color(0xFF187BCD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💰 ', style: TextStyle(fontSize: 12)),
          Text(
            '${skin.price}',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
