import { setup } from "./setup";
import mudConfig from "contracts/mud.config";

const init = () => {

}

const {
  components,
  systemCalls: { increment },
  network,
} = await setup();
