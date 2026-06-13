export const validationMiddleware = (schema) => {
    return async (req, res, next) => {
        if (!req.body) {  // Ensure request body exists
            return res.status(400).json({ message: "Request body is missing" });
        }

        const schemaKeys = Object.keys(schema);  // ['body']
        const validationErrors = [];

        for (const key of schemaKeys) {
            if (!req[key]) {
                validationErrors.push({ message: `${key} is required` });
                continue;
            }
            const validationResult = schema[key].validate(req[key], { abortEarly: false }).error;
            if (validationResult) {
                validationErrors.push(...validationResult.details);
            }
        }

        if (validationErrors.length) {
            return res.status(400).json({ message: "Validation error", error: validationErrors });
        }
        
        next();  // Proceed to the next middleware
    };
};
