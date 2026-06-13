




export const errorHandler = (api) => {
    return (req, res, next) => {
        api(req, res, next).catch((error) => {
            console.log(`Error in ${req.url} from errorHandler middlerware`, error);
            return next(new Error(error.message, {cause: 500}))
        })
    }
} 


// error handling middleware to convert error from html response => json response
export const globalErrorHandler = (err, req, res, next) => {
    console.log(`Global error handler: ${err.message}`);
    return res.status(500).json({message: 'Something went wrong', err: err.message})
}


// export const errorHandler = (api) => {
//     return async (req, res, next) => {
//         try {
//             await api(req, res, next);
//         } catch (error) {
//             console.log(Error in ${req.url} from error handler middleware, error);
//             return next({ message: error.message, statusCode: 500 });
//         }
//     };
// };
// export const globalhandelrMW = (error, req, res, next) => {
//     console.log(Global error handler: ${error.message});
//     return res.status(error.statusCode || 500).json({ message: "Something went wrong", error: error.message });
// };