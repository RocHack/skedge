(function () {
  MAIN = 0;
  LAB = 1;
  REC = 2;
  LL = 3;
  WRK = 4;

  OPEN = 0;
  CLOSED = 1;
  CANCELLED = 2;

  type2name = function (type, short, ignoreSection) {
      if (type == MAIN) {
        return ignoreSection ? "" : "Section";
      }
      if (type == LAB) {
        return "Lab";
      }
      if (type == REC) {
        return short ? "REC" : "Recitation";
      }
      if (type == LL) {
        return short ? "L/L" : "Lab Lecture";
      }
      if (type == WRK) {
        return short ? "WRK" : "Workshop";
      }
      return "";
    }
})();