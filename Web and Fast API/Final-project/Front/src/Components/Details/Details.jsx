import React, { useEffect, useRef, useState } from "react";
import { X } from "lucide-react";

export default function Details({ onClose, item }) {
  const modalRef = useRef();
  const [data, setData] = useState(item || null);
  const [loading, setLoading] = useState(!item);
  const [fullScreenImage, setFullScreenImage] = useState(null);

  useEffect(() => {
    if (item) {
      setData(item);
      setLoading(false);
    }
  }, [item]);

  const closeModal = (e) => {
    if (modalRef.current && modalRef.current === e.target) {
      onClose();
    }
  };

  if (loading) return <p className="text-white">Loading...</p>;
  if (!data) return <p className="text-white">No details available.</p>;

  return (
    <div
      ref={modalRef}
      onClick={closeModal}
      className="fixed inset-0 flex justify-center items-center bg-black bg-opacity-50 z-50"
    >
      <div className="relative text-white bg-gray-900 p-6 rounded-3xl w-full max-w-4xl shadow-lg overflow-y-auto max-h-[90vh]">
        {/* Close Button */}
        <button onClick={onClose} className="absolute top-3 right-3 text-white">
          <X className="w-6 h-6 cursor-pointer" />
        </button>

        {/* Content */}
        <div className="text-center">
          <h2 className="text-xl font-bold text-orange-300 mb-4">
            PCB #{data._id}
          </h2>

          {/* Images Section */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            {[
              { src: data.image_url, label: "Uploaded Image" },
              { src: data.annotated_image_url, label: "Bounded Boxes" },
              { src: data.heatmap_url, label: "Heatmap Image" },
            ].map(({ src, label }, index) => (
              <div key={index} className="cursor-pointer">
                <img
                  src={src}
                  alt={label}
                  className="w-full h-48 object-cover border border-orange-300 rounded-lg"
                  onClick={() => setFullScreenImage(src)}
                />
                <p className="mt-2 text-sm text-gray-300">{label}</p>
              </div>
            ))}
          </div>

          {/* Defect List */}
          <div className="mt-6 text-left">
            <h3 className="text-lg font-semibold text-white mb-2">
              Defect Details:
            </h3>
            <ul className="list-disc list-inside text-gray-300">
              {data.predictions.length > 0 ? (
                data.predictions.map((defect, index) => (
                  <li key={index} className="text-red-500">
                    {defect.class_name} (Confidence:{" "}
                    {Math.round(defect.confidence * 100)}%)
                  </li>
                ))
              ) : (
                <p className="text-green-400">No defects detected</p>
              )}
            </ul>
          </div>
        </div>
      </div>

      {/* Full Screen Image */}
      {fullScreenImage && (
        <div
          className="fixed inset-0 flex justify-center items-center bg-black bg-opacity-90 z-50"
          onClick={() => setFullScreenImage(null)}
        >
          <img
            src={fullScreenImage}
            alt="Full Screen View"
            className="max-w-full max-h-full"
          />
        </div>
      )}
    </div>
  );
}
