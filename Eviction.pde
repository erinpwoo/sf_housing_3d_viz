class Eviction {
  double lon;
  double lat;
  int[] date;
  String area;
  String addr;
  String gen_status;
  String fips_code;
  
  Eviction(Double lon, Double lat, int[] date, String area, String addr, String gen_status, String fips_code) {
    this.lon = lon;
    this.lat = lat;
    this.date = date;
    this.area = area;
    this.addr = addr;
    this.gen_status = gen_status;
    this.fips_code = fips_code;
  }
}