import 'package:flutter_test/flutter_test.dart';
import 'package:points_verts/services/adeps.dart';

// Shape of https://www.am-sport.cfwb.be/adeps/pv_data.asp?type=map: one line,
// 10 `;`-separated fields per walk, no line breaks between walks.
const _body =
    '24717;NM-ITHEN;M;50.7892628;4.6891895;Brabant wallon;11-10-2026;Dimanche 11 Octobre 2026;Grez-Doiceau;ptvert_annule;'
    '24719;NIVELLES;M;50.6084259;4.3211442;Brabant wallon;11-10-2026;Dimanche 11 Octobre 2026;Nivelles;ptvert;'
    '24720;SPA;O;50.49;5.86;Liège;11-10-2026;Dimanche 11 Octobre 2026;Spa;ptvert_modifie;'
    '24721;HUY;M;50.51;5.24;Liège;11-10-2026;Dimanche 11 Octobre 2026;Huy;inconnu;';

void main() {
  test('parses id and status of every walk', () {
    final walks = parseWebsiteWalks(_body);

    expect(walks.map((w) => w.id), [24717, 24719, 24720, 24721]);
    expect(walks.map((w) => w.status), ['Annulé', 'OK', 'Modifié', null]);
  });

  test('returns nothing for an empty body', () {
    expect(parseWebsiteWalks(''), isEmpty);
  });
}
