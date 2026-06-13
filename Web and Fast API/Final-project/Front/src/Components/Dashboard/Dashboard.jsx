import React, { useEffect, useState } from "react";
import axios from "axios";
import "./Dashboard.css";
import {
  PieChart,
  Pie,
  Cell,
  Tooltip,
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  ResponsiveContainer,
} from "recharts";

export default function Dashboard() {
  const [summary, setSummary] = useState(null);
  const [dailyData, setDailyData] = useState([]);
  const accessToken = localStorage.getItem("accessToken");

  useEffect(() => {
    axios
      .get("http://13.48.37.38:3000/detection/Dashboard", {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
      })
      .then((response) => {
        const summaryData = response.data.summary;
        if (summaryData) {
          setSummary(summaryData);

          if (
            summaryData.weekly_summary &&
            summaryData.weekly_summary.length > 0
          ) {
            const transformedData = summaryData.weekly_summary.map((entry) => ({
              name: entry.name,
              faultRate: entry.faultRate,
            }));
            setDailyData(transformedData);
          } else {
            console.warn("Weekly summary is empty or missing");
          }
        } else {
          console.error("Summary data is missing in the response");
        }
      })
      .catch((error) => {
        console.error("Error fetching summary:", error);
      });
  }, []);

  if (!summary) {
    return <p className="text-center mt-10 text-gray-500">Loading...</p>;
  }

  return (
    
    <div className="w-full px-4 lg:px-8 py-8 space-y-12">
      <p className="text-gray-100 text-center mb-8">
        Last updated: {new Date().toLocaleString("en-US", {
          month: "short",
          day: "2-digit",
          year: "numeric",
          hour: "2-digit",
          minute: "2-digit",
          hour12: true,
        })}
      </p>
      {/* === Pair 1: Defect Percentages + Pie Chart === */}
      <div className="flex flex-col md:flex-row">
        {/* Left: Defect Percentages */}
        <section className="rounded-2xl p-6 basis-full md:basis-6/12">
          <h3 className="text-xl font-semibold mb-4">Defects Percentage</h3>
          <div className="grid grid-cols-2 gap-4">
            {summary.defect_percentages.map((defect, index) => (
              <div
                key={index}
                className="bgc text-yellow-400 p-4 rounded-xl flex flex-row flex-wrap justify-between items-center shadow"
              >
                <span>{defect.name}</span>
                <span>{defect.percentage}%</span>
              </div>
            ))}
          </div>
        </section>

        {/* Spacer */}
        <div className="hidden lg:block basis-2/12" />

        {/* Right: Pie Chart */}
        <section className="rounded-2xl p-6 basis-full md:basis-4/12 ">
          <h3 className="text-sm font-semibold mb-4">Defective vs Non-Defective</h3>
          <div className="bgc shadow flex justify-center rounded-2xl">
            <DefectivePieChart data={summary.defective_chart} />
          </div>
        </section>
      </div>

      {/* === Pair 2: Line Chart + Recent Defects === */}
      <div className="flex flex-col lg:flex-row">
        {/* Left: Line Chart */}
        <section className="rounded-2xl p-6 basis-full md:basis-6/12 ">
          <h3 className="text-xl font-semibold mb-4">Daily Batch Fault Detection</h3>
          <div className="bgc shadow ps-1 py-3 pe-3 rounded-2xl w-full h-[300px]">
            <DailyFaultChart data={dailyData} />
          </div>
        </section>

        {/* Spacer */}
        <div className="hidden lg:block basis-2/12" />

        {/* Right: Recent Defects */}
        <section className="rounded-2xl p-6 basis-full md:basis-4/12 ">
          <h3 className="text-xl font-semibold mb-4">Recent Defects</h3>
          <div className="bgc shadow p-3 rounded-2xl text-yellow-500 space-y-4">
            {[...summary.recent_defects].reverse().map((pcb, index) => (
              <div key={index} className="flex gap-4 items-start">
                <div className="text-3xl">
                  <i className="fa-solid fa-microchip"></i>
                </div>
                <div>
                  <p className="font-bold">{pcb.pcb_id}</p>
                  <p className="text-sm">Defects: {pcb.defects.join(", ")}</p>
                </div>
              </div>
            ))}
          </div>
        </section>
      </div>
    </div>
  );
}

// Pie Chart Component
const COLORS = ["#009669", "#eda10d"];
const DefectivePieChart = ({ data }) => (
  <PieChart width={250} height={250}>
    <Pie
      data={data}
      cx="50%"
      cy="50%"
      outerRadius={100}
      fill="#8884d8"
      dataKey="value"
    >
      {data.map((entry, index) => (
        <Cell key={`cell-${index}`} fill={COLORS[index]} />
      ))}
    </Pie>
    <Tooltip />
  </PieChart>
);

// Line Chart Component
const DailyFaultChart = ({ data }) => (
  <ResponsiveContainer width="100%" height="100%">
    <LineChart data={data}>
      <CartesianGrid strokeDasharray="3 3" />
      <XAxis dataKey="name" tick={{ fill: "#009669", fontSize: 14 }} />
      <YAxis domain={[90, 100]} tick={{ fill: "#009669" }} />
      <Tooltip
        labelFormatter={(label) => `Day: ${label}`}
        formatter={(value) => [`${value}%`, "Fault Rate"]}
      />
      <Line
        type="monotone"
        dataKey="faultRate"
        stroke="#eda10d"
        strokeWidth={2}
        dot={{ r: 4 }}
      />
    </LineChart>
  </ResponsiveContainer>
);
