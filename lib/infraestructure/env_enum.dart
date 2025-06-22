enum EnvEnum {
  dev,
  test,
  prod,
  stag,
}

EnvEnum envEnumSet(String envString) {
  switch (envString.toLowerCase()) {
    case "dev":
      return EnvEnum.dev;
    case "test":
      return EnvEnum.test;
    case "prod":
      return EnvEnum.prod;
    case "stag":
      return EnvEnum.stag;
  }
  return EnvEnum.prod; 
}

String envEnumGet(EnvEnum envEnum) {
  switch (envEnum) {
    case EnvEnum.dev:
      return "dev";
    case EnvEnum.test:
      return "test";
    case EnvEnum.prod:
      return "prod";
    case EnvEnum.stag:
      return "stag";
  }
}
