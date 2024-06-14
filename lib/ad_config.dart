// final adConfig = _googlePlayAdConfig;
// final adConfig = _ruStoreAdConfig;
final adConfig = _appleAdConfig;

class _AdConfiguration {
  final String openPackAd;
  final String packBottomBanner;
  final String albumBottomBanner;

  _AdConfiguration({
    required this.openPackAd,
    required this.packBottomBanner,
    required this.albumBottomBanner,
  });
}

final _ruStoreAdConfig = _AdConfiguration(
  openPackAd: "R-M-9326097-3",
  packBottomBanner: "R-M-9326097-2",
  albumBottomBanner: "R-M-9326097-1",
);

final _googlePlayAdConfig = _AdConfiguration(
  openPackAd: "R-M-9368471-3",
  packBottomBanner: "R-M-9368471-2",
  albumBottomBanner: "R-M-9368471-1",
);

final _appleAdConfig = _AdConfiguration(
  openPackAd: "R-M-9368729-3",
  packBottomBanner: "R-M-9368729-1",
  albumBottomBanner: "R-M-9368729-2",
);
