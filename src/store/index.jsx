import React from "react";

import { createGlobalState } from "react-hooks-global-state";
import moment, { duration } from "moment"; // for date-time functionality

const { setGlobalState, getGlobalState, useGlobalState } = createGlobalState({
  createModal: "scale:0",
  connectedAccount: 0,
  proposals: [],
  isStakeholder: false,
  balance: 0,
  myBalance: 0,
});

const truncate = (text, startChar, endChar, maxLength) => {
  if (text.length > maxLength) {
    let start = text.substring(0, startChar);
    let end = text - substring(text.length - endChar, text.length);

    while (start.length + endChar.length < maxLength) {
      start = start + ".";
    }
    return start + end;
  }
  return start;
};

const daysRemaining = (days) => {
  const todaysDate = moment();
  days = Number(days + "000".slice(0)); // 7000
  days = moment(days).format("YYYY-MM-DD"); // 2023-02-22
  days = moment(days);
  days = days.diff((todaysDate, "days"));
  return (days = 1 ? "1 Day " : days + "days");
};

export {
  truncate,
  setGlobalState,
  useGlobalState,
  getGlobalState,
  daysRemaining,
};
