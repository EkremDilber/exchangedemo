import 'package:exchangedemo/config/palette.dart';
import 'package:exchangedemo/screens/grafik_sayfasi.dart';
import 'package:exchangedemo/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  @override
  void initState() {
    super.initState();
    dovizPariteleriniGetir();
    _uygulamaSurumunuGetir();
  }

  String secilenDovizCinsi = 'USD'; // Varsayılan olarak gelecek döviz cinsi
  Map<String, dynamic>? dovizPariteleri;

  String _appVersion = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.arkaPlan,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 100,
            child: Image(
              image: AssetImage("assets/logo/appbar_logo.png"),
            ),
          ),
        ),
        backgroundColor: Palette.doaTuruncu,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: DropdownButton<String>(
                    borderRadius: BorderRadius.circular(8),
                    value: secilenDovizCinsi,
                    //API'den gelen doviz cesitleri bir listeye de atılabilir ve items'a parselanabilir.
                    items: ['TRY', 'USD', 'GBP', 'EUR']
                        .map((doviz) => DropdownMenuItem(
                              value: doviz,
                              child: Text(doviz),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          secilenDovizCinsi = value;
                          dovizPariteleri = null;
                        });
                        dovizPariteleriniGetir();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                dovizPariteleri == null
                    ? DovizShimmer()
                    : SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 330,
                        child: ListView(
                          children: ['TRY', 'USD', 'GBP', 'EUR']
                              .where((doviz) => doviz != secilenDovizCinsi)
                              .map(
                                (doviz) => DovizKarti(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GrafikSayfasi(
                                          secilenDoviz: secilenDovizCinsi,
                                          hedefDoviz: doviz,
                                        ),
                                      ),
                                    );
                                  },
                                  doviz: doviz,
                                  dovizPariteleri: dovizPariteleri,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                SizedBox(height: 5),
                //DropdownButton ile döviz seçimi yaptığınızda zaten bilgiler güncelleniyor. Mülakatta istendiği için ElevatedButton ekledim.
                Buton(
                  onPressed: () async {
                    setState(() {
                      dovizPariteleri = null;
                    });
                    await dovizPariteleriniGetir();
                  },
                  arkaPlanRengi: Palette.doaKoyuTuruncu,
                  butonMetni: "Bilgileri Yenile",
                ),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        textStyle:
                            TextStyle(color: Colors.black87, fontSize: 14),
                      ),
                      text: 'Uygulama versiyonu  ',
                      children: [
                        TextSpan(
                          text: _appVersion.isEmpty ? '' : _appVersion,
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future dovizPariteleriniGetir() async {
    //Şuan 1379 istek kotası kaldı
    final url =
        'https://v6.exchangerate-api.com/v6/affce82a6d64724d05668afc/latest/$secilenDovizCinsi';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final pariteler = json.decode(response.body);
        setState(() {
          dovizPariteleri = pariteler['conversion_rates'];
        });
      } else {
        Fluttertoast.showToast(
          msg: "Döviz verileri ile bağlantı sağlanamadı.",
          backgroundColor: Palette.doaTuruncu,
          textColor: Colors.white,
          fontSize: 16,
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(),
        backgroundColor: Palette.doaTuruncu,
        textColor: Colors.white,
        fontSize: 16,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  Future<void> _uygulamaSurumunuGetir() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version}';
    });
  }
}
