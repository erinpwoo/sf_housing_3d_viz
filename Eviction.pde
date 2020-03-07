class Eviction {
  double lon;
  double lat;
  int[] date;
  String area;
  String addr;
  String gen_status;
  String fips_code;
  int date_num;
  
  Eviction(Double lon, Double lat, int[] date, String area, String addr, String gen_status, String fips_code, int date_num) {
    this.lon = lon;
    this.lat = lat;
    this.date = date;
    this.area = area;
    this.addr = addr;
    this.gen_status = gen_status;
    this.fips_code = fips_code;
    this.date_num = date_num;
  }
}

void drawPoint(Eviction evic) {
   pushMatrix();
   translate(width/2, height/2);
   strokeWeight(1);
    
   point((float)(evic.lon + 122)*100, (float)(evic.lat - 70)*100, evic.date_num);
}