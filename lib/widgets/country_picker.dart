import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class Country {
  final String flag;
  final String name;
  final String dialCode;
  const Country({required this.flag, required this.name, required this.dialCode});
}

const List<Country> kCountries = [
  Country(flag: '🇹🇳', name: 'Tunisia', dialCode: '+216'),
  Country(flag: '🇦🇫', name: 'Afghanistan', dialCode: '+93'),
  Country(flag: '🇦🇱', name: 'Albania', dialCode: '+355'),
  Country(flag: '🇩🇿', name: 'Algeria', dialCode: '+213'),
  Country(flag: '🇦🇩', name: 'Andorra', dialCode: '+376'),
  Country(flag: '🇦🇴', name: 'Angola', dialCode: '+244'),
  Country(flag: '🇦🇬', name: 'Antigua & Barbuda', dialCode: '+1-268'),
  Country(flag: '🇦🇷', name: 'Argentina', dialCode: '+54'),
  Country(flag: '🇦🇲', name: 'Armenia', dialCode: '+374'),
  Country(flag: '🇦🇺', name: 'Australia', dialCode: '+61'),
  Country(flag: '🇦🇹', name: 'Austria', dialCode: '+43'),
  Country(flag: '🇦🇿', name: 'Azerbaijan', dialCode: '+994'),
  Country(flag: '🇧🇸', name: 'Bahamas', dialCode: '+1-242'),
  Country(flag: '🇧🇭', name: 'Bahrain', dialCode: '+973'),
  Country(flag: '🇧🇩', name: 'Bangladesh', dialCode: '+880'),
  Country(flag: '🇧🇧', name: 'Barbados', dialCode: '+1-246'),
  Country(flag: '🇧🇾', name: 'Belarus', dialCode: '+375'),
  Country(flag: '🇧🇪', name: 'Belgium', dialCode: '+32'),
  Country(flag: '🇧🇿', name: 'Belize', dialCode: '+501'),
  Country(flag: '🇧🇯', name: 'Benin', dialCode: '+229'),
  Country(flag: '🇧🇹', name: 'Bhutan', dialCode: '+975'),
  Country(flag: '🇧🇴', name: 'Bolivia', dialCode: '+591'),
  Country(flag: '🇧🇦', name: 'Bosnia & Herzegovina', dialCode: '+387'),
  Country(flag: '🇧🇼', name: 'Botswana', dialCode: '+267'),
  Country(flag: '🇧🇷', name: 'Brazil', dialCode: '+55'),
  Country(flag: '🇧🇳', name: 'Brunei', dialCode: '+673'),
  Country(flag: '🇧🇬', name: 'Bulgaria', dialCode: '+359'),
  Country(flag: '🇧🇫', name: 'Burkina Faso', dialCode: '+226'),
  Country(flag: '🇧🇮', name: 'Burundi', dialCode: '+257'),
  Country(flag: '🇨🇻', name: 'Cabo Verde', dialCode: '+238'),
  Country(flag: '🇰🇭', name: 'Cambodia', dialCode: '+855'),
  Country(flag: '🇨🇲', name: 'Cameroon', dialCode: '+237'),
  Country(flag: '🇨🇦', name: 'Canada', dialCode: '+1'),
  Country(flag: '🇨🇫', name: 'Central African Republic', dialCode: '+236'),
  Country(flag: '🇹🇩', name: 'Chad', dialCode: '+235'),
  Country(flag: '🇨🇱', name: 'Chile', dialCode: '+56'),
  Country(flag: '🇨🇳', name: 'China', dialCode: '+86'),
  Country(flag: '🇨🇴', name: 'Colombia', dialCode: '+57'),
  Country(flag: '🇰🇲', name: 'Comoros', dialCode: '+269'),
  Country(flag: '🇨🇬', name: 'Congo', dialCode: '+242'),
  Country(flag: '🇨🇩', name: 'Congo (DRC)', dialCode: '+243'),
  Country(flag: '🇨🇷', name: 'Costa Rica', dialCode: '+506'),
  Country(flag: '🇭🇷', name: 'Croatia', dialCode: '+385'),
  Country(flag: '🇨🇺', name: 'Cuba', dialCode: '+53'),
  Country(flag: '🇨🇾', name: 'Cyprus', dialCode: '+357'),
  Country(flag: '🇨🇿', name: 'Czech Republic', dialCode: '+420'),
  Country(flag: '🇩🇰', name: 'Denmark', dialCode: '+45'),
  Country(flag: '🇩🇯', name: 'Djibouti', dialCode: '+253'),
  Country(flag: '🇩🇴', name: 'Dominican Republic', dialCode: '+1-809'),
  Country(flag: '🇪🇨', name: 'Ecuador', dialCode: '+593'),
  Country(flag: '🇪🇬', name: 'Egypt', dialCode: '+20'),
  Country(flag: '🇸🇻', name: 'El Salvador', dialCode: '+503'),
  Country(flag: '🇬🇶', name: 'Equatorial Guinea', dialCode: '+240'),
  Country(flag: '🇪🇷', name: 'Eritrea', dialCode: '+291'),
  Country(flag: '🇪🇪', name: 'Estonia', dialCode: '+372'),
  Country(flag: '🇸🇿', name: 'Eswatini', dialCode: '+268'),
  Country(flag: '🇪🇹', name: 'Ethiopia', dialCode: '+251'),
  Country(flag: '🇫🇯', name: 'Fiji', dialCode: '+679'),
  Country(flag: '🇫🇮', name: 'Finland', dialCode: '+358'),
  Country(flag: '🇫🇷', name: 'France', dialCode: '+33'),
  Country(flag: '🇬🇦', name: 'Gabon', dialCode: '+241'),
  Country(flag: '🇬🇲', name: 'Gambia', dialCode: '+220'),
  Country(flag: '🇬🇪', name: 'Georgia', dialCode: '+995'),
  Country(flag: '🇩🇪', name: 'Germany', dialCode: '+49'),
  Country(flag: '🇬🇭', name: 'Ghana', dialCode: '+233'),
  Country(flag: '🇬🇷', name: 'Greece', dialCode: '+30'),
  Country(flag: '🇬🇩', name: 'Grenada', dialCode: '+1-473'),
  Country(flag: '🇬🇹', name: 'Guatemala', dialCode: '+502'),
  Country(flag: '🇬🇳', name: 'Guinea', dialCode: '+224'),
  Country(flag: '🇬🇼', name: 'Guinea-Bissau', dialCode: '+245'),
  Country(flag: '🇬🇾', name: 'Guyana', dialCode: '+592'),
  Country(flag: '🇭🇹', name: 'Haiti', dialCode: '+509'),
  Country(flag: '🇭🇳', name: 'Honduras', dialCode: '+504'),
  Country(flag: '🇭🇺', name: 'Hungary', dialCode: '+36'),
  Country(flag: '🇮🇸', name: 'Iceland', dialCode: '+354'),
  Country(flag: '🇮🇳', name: 'India', dialCode: '+91'),
  Country(flag: '🇮🇩', name: 'Indonesia', dialCode: '+62'),
  Country(flag: '🇮🇷', name: 'Iran', dialCode: '+98'),
  Country(flag: '🇮🇶', name: 'Iraq', dialCode: '+964'),
  Country(flag: '🇮🇪', name: 'Ireland', dialCode: '+353'),
  Country(flag: '🇮🇱', name: 'Israel', dialCode: '+972'),
  Country(flag: '🇮🇹', name: 'Italy', dialCode: '+39'),
  Country(flag: '🇯🇲', name: 'Jamaica', dialCode: '+1-876'),
  Country(flag: '🇯🇵', name: 'Japan', dialCode: '+81'),
  Country(flag: '🇯🇴', name: 'Jordan', dialCode: '+962'),
  Country(flag: '🇰🇿', name: 'Kazakhstan', dialCode: '+7'),
  Country(flag: '🇰🇪', name: 'Kenya', dialCode: '+254'),
  Country(flag: '🇰🇼', name: 'Kuwait', dialCode: '+965'),
  Country(flag: '🇰🇬', name: 'Kyrgyzstan', dialCode: '+996'),
  Country(flag: '🇱🇦', name: 'Laos', dialCode: '+856'),
  Country(flag: '🇱🇻', name: 'Latvia', dialCode: '+371'),
  Country(flag: '🇱🇧', name: 'Lebanon', dialCode: '+961'),
  Country(flag: '🇱🇸', name: 'Lesotho', dialCode: '+266'),
  Country(flag: '🇱🇷', name: 'Liberia', dialCode: '+231'),
  Country(flag: '🇱🇾', name: 'Libya', dialCode: '+218'),
  Country(flag: '🇱🇮', name: 'Liechtenstein', dialCode: '+423'),
  Country(flag: '🇱🇹', name: 'Lithuania', dialCode: '+370'),
  Country(flag: '🇱🇺', name: 'Luxembourg', dialCode: '+352'),
  Country(flag: '🇲🇬', name: 'Madagascar', dialCode: '+261'),
  Country(flag: '🇲🇼', name: 'Malawi', dialCode: '+265'),
  Country(flag: '🇲🇾', name: 'Malaysia', dialCode: '+60'),
  Country(flag: '🇲🇻', name: 'Maldives', dialCode: '+960'),
  Country(flag: '🇲🇱', name: 'Mali', dialCode: '+223'),
  Country(flag: '🇲🇹', name: 'Malta', dialCode: '+356'),
  Country(flag: '🇲🇷', name: 'Mauritania', dialCode: '+222'),
  Country(flag: '🇲🇺', name: 'Mauritius', dialCode: '+230'),
  Country(flag: '🇲🇽', name: 'Mexico', dialCode: '+52'),
  Country(flag: '🇲🇩', name: 'Moldova', dialCode: '+373'),
  Country(flag: '🇲🇨', name: 'Monaco', dialCode: '+377'),
  Country(flag: '🇲🇳', name: 'Mongolia', dialCode: '+976'),
  Country(flag: '🇲🇪', name: 'Montenegro', dialCode: '+382'),
  Country(flag: '🇲🇦', name: 'Morocco', dialCode: '+212'),
  Country(flag: '🇲🇿', name: 'Mozambique', dialCode: '+258'),
  Country(flag: '🇲🇲', name: 'Myanmar', dialCode: '+95'),
  Country(flag: '🇳🇦', name: 'Namibia', dialCode: '+264'),
  Country(flag: '🇳🇵', name: 'Nepal', dialCode: '+977'),
  Country(flag: '🇳🇱', name: 'Netherlands', dialCode: '+31'),
  Country(flag: '🇳🇿', name: 'New Zealand', dialCode: '+64'),
  Country(flag: '🇳🇮', name: 'Nicaragua', dialCode: '+505'),
  Country(flag: '🇳🇪', name: 'Niger', dialCode: '+227'),
  Country(flag: '🇳🇬', name: 'Nigeria', dialCode: '+234'),
  Country(flag: '🇰🇵', name: 'North Korea', dialCode: '+850'),
  Country(flag: '🇲🇰', name: 'North Macedonia', dialCode: '+389'),
  Country(flag: '🇳🇴', name: 'Norway', dialCode: '+47'),
  Country(flag: '🇴🇲', name: 'Oman', dialCode: '+968'),
  Country(flag: '🇵🇰', name: 'Pakistan', dialCode: '+92'),
  Country(flag: '🇵🇼', name: 'Palau', dialCode: '+680'),
  Country(flag: '🇵🇦', name: 'Panama', dialCode: '+507'),
  Country(flag: '🇵🇬', name: 'Papua New Guinea', dialCode: '+675'),
  Country(flag: '🇵🇾', name: 'Paraguay', dialCode: '+595'),
  Country(flag: '🇵🇪', name: 'Peru', dialCode: '+51'),
  Country(flag: '🇵🇭', name: 'Philippines', dialCode: '+63'),
  Country(flag: '🇵🇱', name: 'Poland', dialCode: '+48'),
  Country(flag: '🇵🇹', name: 'Portugal', dialCode: '+351'),
  Country(flag: '🇶🇦', name: 'Qatar', dialCode: '+974'),
  Country(flag: '🇷🇴', name: 'Romania', dialCode: '+40'),
  Country(flag: '🇷🇺', name: 'Russia', dialCode: '+7'),
  Country(flag: '🇷🇼', name: 'Rwanda', dialCode: '+250'),
  Country(flag: '🇸🇦', name: 'Saudi Arabia', dialCode: '+966'),
  Country(flag: '🇸🇳', name: 'Senegal', dialCode: '+221'),
  Country(flag: '🇷🇸', name: 'Serbia', dialCode: '+381'),
  Country(flag: '🇸🇱', name: 'Sierra Leone', dialCode: '+232'),
  Country(flag: '🇸🇬', name: 'Singapore', dialCode: '+65'),
  Country(flag: '🇸🇰', name: 'Slovakia', dialCode: '+421'),
  Country(flag: '🇸🇮', name: 'Slovenia', dialCode: '+386'),
  Country(flag: '🇸🇴', name: 'Somalia', dialCode: '+252'),
  Country(flag: '🇿🇦', name: 'South Africa', dialCode: '+27'),
  Country(flag: '🇰🇷', name: 'South Korea', dialCode: '+82'),
  Country(flag: '🇸🇸', name: 'South Sudan', dialCode: '+211'),
  Country(flag: '🇪🇸', name: 'Spain', dialCode: '+34'),
  Country(flag: '🇱🇰', name: 'Sri Lanka', dialCode: '+94'),
  Country(flag: '🇸🇩', name: 'Sudan', dialCode: '+249'),
  Country(flag: '🇸🇷', name: 'Suriname', dialCode: '+597'),
  Country(flag: '🇸🇪', name: 'Sweden', dialCode: '+46'),
  Country(flag: '🇨🇭', name: 'Switzerland', dialCode: '+41'),
  Country(flag: '🇸🇾', name: 'Syria', dialCode: '+963'),
  Country(flag: '🇹🇼', name: 'Taiwan', dialCode: '+886'),
  Country(flag: '🇹🇯', name: 'Tajikistan', dialCode: '+992'),
  Country(flag: '🇹🇿', name: 'Tanzania', dialCode: '+255'),
  Country(flag: '🇹🇭', name: 'Thailand', dialCode: '+66'),
  Country(flag: '🇹🇱', name: 'Timor-Leste', dialCode: '+670'),
  Country(flag: '🇹🇬', name: 'Togo', dialCode: '+228'),
  Country(flag: '🇹🇹', name: 'Trinidad & Tobago', dialCode: '+1-868'),
  Country(flag: '🇹🇷', name: 'Turkey', dialCode: '+90'),
  Country(flag: '🇹🇲', name: 'Turkmenistan', dialCode: '+993'),
  Country(flag: '🇺🇬', name: 'Uganda', dialCode: '+256'),
  Country(flag: '🇺🇦', name: 'Ukraine', dialCode: '+380'),
  Country(flag: '🇦🇪', name: 'United Arab Emirates', dialCode: '+971'),
  Country(flag: '🇬🇧', name: 'United Kingdom', dialCode: '+44'),
  Country(flag: '🇺🇸', name: 'United States', dialCode: '+1'),
  Country(flag: '🇺🇾', name: 'Uruguay', dialCode: '+598'),
  Country(flag: '🇺🇿', name: 'Uzbekistan', dialCode: '+998'),
  Country(flag: '🇻🇪', name: 'Venezuela', dialCode: '+58'),
  Country(flag: '🇻🇳', name: 'Vietnam', dialCode: '+84'),
  Country(flag: '🇾🇪', name: 'Yemen', dialCode: '+967'),
  Country(flag: '🇿🇲', name: 'Zambia', dialCode: '+260'),
  Country(flag: '🇿🇼', name: 'Zimbabwe', dialCode: '+263'),
];

class CountryPickerButton extends StatelessWidget {
  final Country selected;
  final ValueChanged<Country> onChanged;

  const CountryPickerButton({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  void _open(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CountryPickerSheet(
        selected: selected,
        onSelected: (c) {
          Navigator.pop(context);
          onChanged(c);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selected.flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 4),
            Text(
              selected.dialCode,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down,
                size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  final Country selected;
  final ValueChanged<Country> onSelected;

  const _CountryPickerSheet({
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchCtrl = TextEditingController();
  List<Country> _filtered = kCountries;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      final q = _searchCtrl.text.toLowerCase();
      setState(() {
        _filtered = q.isEmpty
            ? kCountries
            : kCountries
                .where((c) =>
                    c.name.toLowerCase().contains(q) ||
                    c.dialCode.contains(q))
                .toList();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search country or code',
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 14, color: AppColors.textHint),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textHint, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final c = _filtered[i];
                  final isSelected = c.dialCode == widget.selected.dialCode &&
                      c.name == widget.selected.name;
                  return ListTile(
                    leading: Text(c.flag,
                        style: const TextStyle(fontSize: 24)),
                    title: Text(
                      c.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: Text(
                      c.dialCode,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onTap: () => widget.onSelected(c),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
