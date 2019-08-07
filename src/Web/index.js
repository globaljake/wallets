import { Elm } from "./Main.elm";
import "./Main.css";
import Wallet from "../Wallets/Wallet";
import Transaction from "../Wallets/Transaction";
import UiIcon from "../Wallets/Ui/Icon";

const app = Elm.Web.Main.init({});

Wallet.init(app);
Transaction.init(app);

UiIcon.start(app);
