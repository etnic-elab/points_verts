enum OdwbPointVertStatus {
  annule,
  modifie,
  ok,
  unknown;

  /// Factory method to convert website status string to enum value
  factory OdwbPointVertStatus.fromString(String webSiteStatus) {
    switch (webSiteStatus) {
      case 'Annulé':
        return OdwbPointVertStatus.annule;
      case 'Modifié':
        return OdwbPointVertStatus.modifie;
      case 'OK':
        return OdwbPointVertStatus.ok;
      default:
        return OdwbPointVertStatus.unknown;
    }
  }
}
