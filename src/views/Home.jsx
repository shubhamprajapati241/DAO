import React from "react";
import Banner from "../components/Banner";
import CreateProposals from "../components/CreateProposal";
import Proposals from "../components/Proposals";

const Home = () => {
  return (
    <>
      <Banner />
      <Proposals />
      <CreateProposals />
    </>
  );
};

export default Home;
