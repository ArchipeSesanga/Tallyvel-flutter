import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The TallyVel logo, in the variants the app needs.
class TallyvelLogo extends StatelessWidget {
  /// The symbol only, in brand colours.
  const TallyvelLogo.symbol({this.height = 36, super.key})
    : _asset = 'tallyvel-symbol';

  /// The symbol only, for dark backgrounds.
  const TallyvelLogo.symbolOnDark({this.height = 36, super.key})
    : _asset = 'tallyvel-symbol-on-dark';

  /// Symbol and wordmark, in brand colours.
  const TallyvelLogo.horizontal({this.height = 36, super.key})
    : _asset = 'tallyvel-horizontal';

  /// Symbol and wordmark, for dark backgrounds.
  const TallyvelLogo.horizontalOnDark({this.height = 36, super.key})
    : _asset = 'tallyvel-horizontal-on-dark';

  /// The rendered height; width follows the artwork's aspect ratio.
  final double height;

  final String _asset;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/TallyVel-logo-kit/svg-masters/$_asset.svg',
      height: height,
      semanticsLabel: 'TallyVel',
    );
  }
}
