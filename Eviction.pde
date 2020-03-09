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
  float lon = map((float)evic.lon, (float)min_lon, (float)max_lon, -3000.0, 3000.0);
  float lat =  map((float)evic.lat, (float)min_lat, (float)max_lat, -3000.0, 3000.0);
  pushMatrix();
  translate(lon, lat, evic.date_num);
  strokeWeight(3);
  translate(width/2, height/2);
  int[] colors = getColorForArea(evic);
  color c = color(colors[0],colors[1],colors[2]);
  stroke(c);
  point(0, 0, 0);
  popMatrix();
}

int[] getColorForArea(Eviction e) {
  int[] colors;
  switch (e.area) {
    case "Tenderloin":
      colors = new int[] {168,14,47};
      break;
    case "West of Twin Peaks":
      colors = new int[] {189,200,122};
      break;
    case "Mission Bay":
      colors = new int[] {158,14,112};
      break;
    case "Outer Richmond":
      colors = new int[] {43,79,34};
      break;
    case "Pacific Heights":
      colors = new int[] {85,172,12};
      break;
    case "Noe Valley":
      colors = new int[] {93,190,178};
      break;
    case "Nob Hill":
      colors = new int[] {36,56,210};
      break;
    case "Visitacion Valley":
      colors = new int[] {168,27,109};
      break;
    case "Glen Park":
      colors = new int[] {235,103,129};
      break;
    case "castro/Upper Market":
      colors = new int[] {137,94,105};
      break;
    case "Presidio":
      colors = new int[] {168,54,31};
      break;
    case "Seacliff":
      colors = new int[] {134,118,79};
      break;
    case "Bayview":
      colors = new int[] {1,212,182};
      break;
    case "Hunters Point":
      colors = new int[] {218,146,35};
      break;
    case "Excelsior":
      colors = new int[] {42,71,47};
      break;
    case "Chinatown":
      colors = new int[] {57,101,182};
      break;
    case "Lincoln Park":
      colors = new int[] {183,232,227};
      break;
    case "Mission":
      colors = new int[] {3,101,158};
      break;
    case "Bernal Heights":
      colors = new int[] {67,96,123};
      break;
    case "Twin Peaks":
      colors = new int[] {163,104,158};
      break;
    case "Presidio Heights":
      colors = new int[] {175,150,239};
      break;
    case "Oceanview/Merced/Ingleside":
      colors = new int[] {184,199,149};
      break;
    case "Lakeshore":
      colors = new int[] {90,125,31};
      break;
    case "Financial District/South Beach":
      colors = new int[] {128,225,183};
      break;
    case "Western Addition":
      colors = new int[] {248,154,90};
      break;
    case "Japantown":  
      colors = new int[] {131,85,71};
      break;
    case "Potrero Hill":
      colors = new int[] {200,92,5};
      break;
    case "Treasure Island":
      colors = new int[] {40,70,124};
      break;
    case "Golden Gate Park":
      colors = new int[] {162,9,146};
      break;
    case "Haight Ashbury":
      colors = new int[] {107,83,19};
      break;
    case "McLaren Park":
      colors = new int[] {223,231,240};
      break;
    case "Inner Sunset":
      colors = new int[] {0,73,23};
      break;
    case "Marina":
      colors = new int[] {174,23,98};
      break;
    case "South of Market":
      colors = new int[] {138,173,94};
      break;
    case "Lone Mountain/USF":
      colors = new int[] {210,94,141};
      break;
    case "Sunset/Parkside":
      colors = new int[] {71,129,136};
      break;
    case "North Beach":
      colors = new int[] {52,44,129};
      break;
    case "Russian Hill":
      colors = new int[] {48,35,76};
      break;
    case "Inner Richmond":
      colors = new int[] {201,143,137};
      break;
    case "Outer Mission":
      colors = new int[] {221,225,133};
      break;
    case "Portola":
      colors = new int[] {18,154,132};
      break;
    case "Hayes Valley":
      colors = new int[] {222,79,27};
      break;
    default:
      colors = new int[] {0,0,0};
  }
  
  return colors;
}