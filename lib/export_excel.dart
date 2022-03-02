import 'dart:io';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ExportExcel{
  Future<void> exportToExcel (List dataTempat, Map detailTempat, String title) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    // Set judul
    sheet.getRangeByName('A1').setText('Business Status');
    sheet.getRangeByName('B1').setText('Formatted Address');
    sheet.getRangeByName('C1').setText('Lat');
    sheet.getRangeByName('D1').setText('Lng');
    sheet.getRangeByName('E1').setText('Icon');
    sheet.getRangeByName('F1').setText('Name');
    sheet.getRangeByName('G1').setText('Rating');
    sheet.getRangeByName('H1').setText('Type');
    sheet.getRangeByName('I1').setText('User Ratings Total');
    sheet.getRangeByName('J1').setText('Formatted Phone Number');
    sheet.getRangeByName('K1').setText('Website');
    
    // Insert Value
    
    for (int i = 0; i < dataTempat.length; i++){
      sheet.getRangeByIndex(i+2, 1).setText(dataTempat[i]['business_status']);
      sheet.getRangeByIndex(i+2, 2).setText(dataTempat[i]['formatted_address']);
      sheet.getRangeByIndex(i+2, 3).setNumber(dataTempat[i]['geometry']['location']['lat']);
      sheet.getRangeByIndex(i+2, 4).setNumber(dataTempat[i]['geometry']['location']['lng']);
      sheet.getRangeByIndex(i+2, 5).setText(dataTempat[i]['icon']);
      sheet.getRangeByIndex(i+2, 6).setText(dataTempat[i]['name']);
      sheet.getRangeByIndex(i+2, 7).setNumber(dataTempat[i]['rating'].toDouble());
      sheet.getRangeByIndex(i+2, 8).setText(getType(dataTempat[i]['types']));
      sheet.getRangeByIndex(i+2, 9).setNumber(dataTempat[i]['user_ratings_total'].toDouble());
      sheet.getRangeByIndex(i+2, 10).setText(detailTempat[dataTempat[i]['place_id']]['formatted_phone_number']);
      sheet.getRangeByIndex(i+2, 11).setText(detailTempat[dataTempat[i]['place_id']]['website']);
    }
    
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();


    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = '$path/Output - $title.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open(fileName);
  }

  Future<void> exportSerpapi (List dataTempat, String title) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    // Set judul
    sheet.getRangeByName('A1').setText('Nama');
    sheet.getRangeByName('B1').setText('Alamat');
    sheet.getRangeByName('C1').setText('Lat');
    sheet.getRangeByName('D1').setText('Long');
    sheet.getRangeByName('E1').setText('Rating');
    sheet.getRangeByName('F1').setText('Review');
    sheet.getRangeByName('G1').setText('Tipe');
    sheet.getRangeByName('H1').setText('Phone Number');
    sheet.getRangeByName('I1').setText('Website');
    sheet.getRangeByName('J1').setText('Description');

    // Insert Value

    for (int i = 0; i < dataTempat.length; i++){
      sheet.getRangeByIndex(i+2, 1).setText(dataTempat[i]['title']);
      sheet.getRangeByIndex(i+2, 2).setText(dataTempat[i]['address']);
      sheet.getRangeByIndex(i+2, 3).setNumber(dataTempat[i]['gps_coordinates']['latitude']);
      sheet.getRangeByIndex(i+2, 4).setNumber(dataTempat[i]['gps_coordinates']['longitude']);
      sheet.getRangeByIndex(i+2, 5).setNumber(dataTempat[i]['rating']);
      sheet.getRangeByIndex(i+2, 6).setNumber(dataTempat[i]['reviews']);
      sheet.getRangeByIndex(i+2, 7).setText(dataTempat[i]['type']);
      sheet.getRangeByIndex(i+2, 8).setText(dataTempat[i]['phone']);
      sheet.getRangeByIndex(i+2, 9).setText(dataTempat[i]['website']);
      sheet.getRangeByIndex(i+2, 10).setText(dataTempat[i]['description']);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();


    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = '$path/Output - $title.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open(fileName);
  }

}

String getType (var type){
  String result = '';
  type.forEach((element) => result+=element+', ');
  
  return result;
}