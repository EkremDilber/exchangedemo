import 'package:exchangedemo/config/palette.dart';
import 'package:exchangedemo/widgets/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GrafikSayfasi extends StatefulWidget {
  final String secilenDoviz;
  final String hedefDoviz;

  const GrafikSayfasi({
    Key? key,
    required this.secilenDoviz,
    required this.hedefDoviz,
  }) : super(key: key);

  @override
  State<GrafikSayfasi> createState() => _GrafikSayfasiState();
}

class _GrafikSayfasiState extends State<GrafikSayfasi> {
  List<Map<String, dynamic>>? son7GunlukVeri;

  @override
  void initState() {
    super.initState();
    veriyiAl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.arkaPlan,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: GeriButonu(),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 75,
                child: Image(
                  image: AssetImage("assets/logo/appbar_logo.png"),
                ),
              ),
              SizedBox(width: 15),
              Text(
                '${widget.secilenDoviz} - ${widget.hedefDoviz} Son 7 Günlük Grafiği',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Palette.doaTuruncu,
      ),
      body: son7GunlukVeri == null
          ? LinearProgressIndicator(
              color: Palette.doaTuruncu,
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          interval: 0.20,
                          getTitlesWidget: (value, meta) {
                            if (meta.max - value < 0.1) return const SizedBox();
                            return Text(
                              value.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < son7GunlukVeri!.length) {
                              String tarih = son7GunlukVeri![value.toInt()]
                                      ['date']
                                  .toString();
                              List<String> tarihParcalari = tarih.split('-');

                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Transform.rotate(
                                  angle: -45 * 3.14159 / 180,
                                  child: Text(
                                    '${tarihParcalari[0]} Aralık',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Text('');
                          },
                          reservedSize: 50,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    minX: 0,
                    maxX: (son7GunlukVeri!.length - 1).toDouble(),
                    minY: son7GunlukVeri!
                            .map((e) => e['rate'] as double)
                            .reduce((a, b) => a < b ? a : b) *
                        0.95,
                    maxY: son7GunlukVeri!
                            .map((e) => e['rate'] as double)
                            .reduce((a, b) => a > b ? a : b) *
                        1.05,
                    lineBarsData: [
                      LineChartBarData(
                        spots: son7GunlukVeri!
                            .asMap()
                            .entries
                            .map((entry) => FlSpot(
                                  entry.key.toDouble(),
                                  entry.value['rate'],
                                ))
                            .toList(),
                        isCurved: true,
                        color: Palette.doaTuruncu,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Palette.doaTuruncu.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> veriyiAl() async {
    try {
      final data =
          await getSon7GunlukVeri(widget.secilenDoviz, widget.hedefDoviz);
      setState(() {
        son7GunlukVeri = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: ${e.toString()}")),
      );
    }
  }

  String parabiriminiDonustur(String parabirimi) {
    // TCMB API'sinden gelen veri TRY yerine YTL olduğu için TRY'yi YTL'ye dönüştürüyorum
    return parabirimi == 'TRY' ? 'YTL' : parabirimi;
  }

  Future<List<Map<String, dynamic>>> getSon7GunlukVeri(
      String baseCurrency, String targetCurrency) async {
    final DateTime now = DateTime.now();
    final DateTime sevenDaysAgo = now.subtract(Duration(days: 7));

    String endDate =
        "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
    String startDate =
        "${sevenDaysAgo.day.toString().padLeft(2, '0')}-${sevenDaysAgo.month.toString().padLeft(2, '0')}-${sevenDaysAgo.year}";

    // Para birimlerini dönüştür
    String apiBaseCurrency = parabiriminiDonustur(baseCurrency);
    String apiTargetCurrency = parabiriminiDonustur(targetCurrency);

    String urlFieldName = 'TP.DK.${apiBaseCurrency}.S.${apiTargetCurrency}';

    String responseFieldName =
        'TP_DK_${apiBaseCurrency}_S_${apiTargetCurrency}';

    final url =
        'https://evds2.tcmb.gov.tr/service/evds/series=$urlFieldName&startDate=$startDate&endDate=$endDate&type=json&key=rnuadaLTeN';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'key': 'rnuadaLTeN',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'];

        return items
            .where((item) => item[responseFieldName] != null)
            .map((item) {
          return {
            "date": item['Tarih'],
            "rate": double.parse(item[responseFieldName]),
          };
        }).toList();
      } else {
        throw Exception("API'den veri alınamadı: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Veri çekme hatası: $e");
    }
  }
}
