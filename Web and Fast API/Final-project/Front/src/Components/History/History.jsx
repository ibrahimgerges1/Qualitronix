import axios from "axios";
import React, { useEffect, useState } from "react";
import "./History.css";
import Details from "../Details/Details";

export default function History() {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showDetailsModal, setShowDetailsModal] = useState(false);
  const [selectedItem, setSelectedItem] = useState(null);
  const [error, setError] = useState(null);
  const accessToken = localStorage.getItem("accessToken");

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await axios.get(
          "http://13.48.37.38:3000/detection/results",
          {
            headers: {
              Authorization: `Bearer ${accessToken}`,
            },
          }
        );
        const results = response.data.results || [];
        const sortedResults = [...results].sort(
          (a, b) => new Date(b.createdAt) - new Date(a.createdAt)
        );
        setData(sortedResults);
      } catch (err) {
        console.error("Error fetching data:", err);
        setError("Failed to fetch results.");
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const formatDate = (isoDate) => {
    const options = {
      year: "numeric",
      month: "short",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
    };
    return new Date(isoDate).toLocaleString(undefined, options);
  };

  if (loading) return <p>Loading...</p>;
  if (error) return <p className="text-red-500">{error}</p>;

  return (
    <div className="row gap-y-2 mt-2">
      {data.map((item, index) => (
        <div key={item._id || index} className="col-xl-3 col-lg-4 col-sm-6">
          <div className="p-4 bg-dark rounded-2xl h-100 d-flex flex-column justify-content-between">
            <div className="row">
              <p className="text-center text-orange-300 ">PCB #{index + 1}</p>
              <div className="col-6">
                <img
                  src={item.image_url}
                  alt={`PCB ${index + 1}`}
                  className="img-fluid rounded"
                />
              </div>
              <div className="col-6 text-light">
                <p>Defects: {item.predictions.length}</p>
                <p>
                  Score:{" "}
                  {(
                    item.predictions.reduce((sum, p) => sum + p.confidence, 0) /
                    item.predictions.length
                  ).toFixed(2)}
                </p>
                <p className="text-sm text-gray-400">
                  Detected: {formatDate(item.createdAt)}
                </p>
              </div>
              <button
                onClick={() => {
                  setSelectedItem(item);
                  setShowDetailsModal(true);
                }}
                className="text-light button-bg col-4 ms-auto mt-2"
              >
                Details <i className="fa fa-arrow-right ms-1"></i>
              </button>
            </div>
          </div>
        </div>
      ))}

      {showDetailsModal && selectedItem && (
        <Details
          item={selectedItem}
          onClose={() => {
            setSelectedItem(null);
            setShowDetailsModal(false);
          }}
        />
      )}
    </div>
  );
}
