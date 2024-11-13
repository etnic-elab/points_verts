import 'package:adeps_website_api/adeps_website_api.dart'
    show WebsitePointVertStatut;
import 'package:odwb_points_verts_api/odwb_points_verts_api.dart'
    show OdwbPointVertStatut;

enum PointVertStatut {
  annule,
  ok,
  unknown;

  factory PointVertStatut.fromString(String status) {
    switch (status.toLowerCase()) {
      case 'annule':
      case 'annulé':
        return PointVertStatut.annule;
      case 'ok':
        return PointVertStatut.ok;
      default:
        return PointVertStatut.unknown;
    }
  }

  factory PointVertStatut.fromOdwb(OdwbPointVertStatut odwbStatut) {
    switch (odwbStatut) {
      case OdwbPointVertStatut.annule:
        return PointVertStatut.annule;
      case OdwbPointVertStatut.ok:
        return PointVertStatut.ok;
      case OdwbPointVertStatut.unknown:
        return PointVertStatut.unknown;
    }
  }

  factory PointVertStatut.fromWebsite(WebsitePointVertStatut websiteStatus) {
    switch (websiteStatus) {
      case WebsitePointVertStatut.annule:
        return PointVertStatut.annule;
      case WebsitePointVertStatut.ok:
        return PointVertStatut.ok;
      case WebsitePointVertStatut.unknown:
        return PointVertStatut.unknown;
    }
  }

  @override
  String toString() {
    switch (this) {
      case PointVertStatut.annule:
        return 'annule';
      case PointVertStatut.ok:
        return 'ok';
      case PointVertStatut.unknown:
        return 'unknown';
    }
  }
}
