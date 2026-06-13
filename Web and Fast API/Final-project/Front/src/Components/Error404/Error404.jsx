import React from "react";
import { Link } from "react-router-dom";
import "./Error404.css";

export default function Error404() {
  return (
    <>
      <div className="container-fluid">
        <div className="row">
          <div className="col-6 content-center">
            <div className="row col-7 m-auto BG-Gradient rounded-2xl center pt-2 pb-5 text-center ">
              <div className="images pb-0 mb-0">
                <img
                  className="col-6 m-auto"
                  src="https://imgur.com/4YwzsaW.jpg"
                  alt="Qualitronix Logo"
                />
              </div>
              <span className="text-9xl mb-4 font-bold pt-0 mt-0 slogan">
                4 0 4
              </span>
              <span className="slogan">Couldn`t find this page</span>
              <div className="mt-3 mb-3">
                <Link to={"/Dashboard"} className="text-2xl slogan">
                  Go Back
                </Link>
              </div>
            </div>
          </div>
          <div className="col-6 panel-background ">
            <div className="images mb-28">
              <img
                className="col-2 m-auto"
                src="https://imgur.com/4YwzsaW.jpg"
                alt="Qualitronix Logo"
              />
              <img
                className="col-6 p-1 m-auto"
                src="https://imgur.com/aM95Zwr.png"
                alt="Qualitronix"
              />
            </div>
            <div className="slogan col-6 text-center m-auto pb-36">
              <h2>Defect Zero, Quality Hero</h2>
              <hr />
            </div>
            <div className="slogan col-6 text-center m-auto pb-20">
              <h2>PCB Defect Detection</h2>
              <hr />
            </div>
            <div className="text-center">
              <Link
                to="/About"
                className="p-2 px-4 rounded-lg text-2xl font-normal drop-shadow-2xl text-white bg-black"
              >
                About
              </Link>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
