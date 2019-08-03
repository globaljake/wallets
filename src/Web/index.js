import { Elm } from "./Main.elm";
import "./Main.css";
import Wallet from "../Wallets/Wallet";

const app = Elm.Web.Main.init({});

Wallet.init(app);
