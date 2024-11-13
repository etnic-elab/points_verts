enum WebsitePointVertStatut {
  annule,
  ok,
  unknown;

  /// Factory method to convert website status string to enum value
  factory WebsitePointVertStatut.fromWebsiteData(String webSiteStatus) {
    switch (webSiteStatus) {
      case 'ptvert_annule':
        return WebsitePointVertStatut.annule;
      case 'ptvert_modifie':
      case 'ptvert':
        return WebsitePointVertStatut.ok;
      default:
        return WebsitePointVertStatut.unknown;
    }
  }
}
