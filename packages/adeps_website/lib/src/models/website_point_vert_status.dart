enum WebsitePointVertStatus {
  annule,
  modifie,
  ok,
  unknown;

  /// Factory method to convert website status string to enum value
  factory WebsitePointVertStatus.fromWebsiteData(String webSiteStatus) {
    switch (webSiteStatus) {
      case 'ptvert_annule':
        return WebsitePointVertStatus.annule;
      case 'ptvert_modifie':
        return WebsitePointVertStatus.modifie;
      case 'ptvert':
        return WebsitePointVertStatus.ok;
      default:
        return WebsitePointVertStatus.unknown;
    }
  }
}
