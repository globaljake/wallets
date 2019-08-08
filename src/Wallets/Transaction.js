const _save = transactions => {
  localStorage.setItem("transactions", JSON.stringify(transactions));
};

const _get = () => JSON.parse(localStorage.getItem("transactions")) || {};

const create = ({ walletId, amount, description = "" }) => {
  if (!walletId || !amount)
    return Promise.reject("Request payload insufficient");
  const wallets = JSON.parse(localStorage.getItem("wallets")) || {};
  if (!wallets[walletId]) return Promise.reject("Item not found");

  const transactions = _get();
  const id = Date.now() + "_transaction";
  const newTransaction = { id, walletId, amount, description };
  _save({ [id]: newTransaction, ...transactions });

  wallets[walletId].available = wallets[walletId].available - amount;
  localStorage.setItem("wallets", JSON.stringify(wallets));

  return Promise.resolve({ transaction: newTransaction });
};

const index = () => {
  const transactions = _get();

  return Promise.resolve({
    feed: Object.keys(transactions).sort(),
    transactions: transactions
  });
};
const indexByWalletId = ({ walletId }) => {
  const transactions = _get();
  const transByWalletId = Object.keys(transactions).reduce((acc, key) => {
    const current = transactions[key];
    if (current.walletId === walletId) {
      acc[current.id] = { ...current };
    }
    return acc;
  }, {});

  return Promise.resolve({
    feed: Object.keys(transByWalletId).sort(),
    transactions: transByWalletId
  });
};

const show = ({ id }) => {
  if (!id) return Promise.reject("Request payload insufficient");
  const transactions = _get();
  if (!transactions[id]) return Promise.reject("Item not found");

  return Promise.resolve({ transaction: transactions[id] });
};

const update = ({ id, amount, description }) => {
  if (!id) return Promise.reject("Request payload insufficient");
  const transactions = _get();
  if (!transactions[id]) return Promise.reject("Item not found");
  if (amount) transactions[id].amount = amount;
  if (description) transactions[id].description = description;
  _save(transactions);

  return Promise.resolve({ transaction: transactions[id] });
};

const delete_ = ({ id }) => {
  if (!id) return Promise.reject("Request payload insufficient");
  const transactions = _get();
  if (!transactions[id]) return Promise.reject("Item not found");
  delete transactions[id];
  _save(transactions);

  return Promise.resolve({ id });
};

export default { create, index, indexByWalletId, show, update, delete_ };
