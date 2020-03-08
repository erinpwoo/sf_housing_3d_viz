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
  float lon = map((float)evic.lon, (float)min_lon, (float)max_lon, -1000.0, 1000.0);
  float lat =  map((float)evic.lat, (float)min_lat, (float)max_lat, -1000.0, 1000.0);
  pushMatrix();
  translate(lon, lat, evic.date_num);
  strokeWeight(10);
  translate(width/2, height/2);
  stroke(247, 95, 0);
  point(0, 0, 0);
  popMatrix();
}