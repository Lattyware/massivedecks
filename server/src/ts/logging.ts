import winston from "winston";

const logFormat = winston.format.printf((info) => {
  const stringRest = JSON.stringify(
    {
      ...info,
      level: undefined,
      message: undefined,
      splat: undefined,
    },
    null,
    2
  );

  if (stringRest !== "{}") {
    return `${info.level}: ${info.message}\n${stringRest}`;
  } else {
    return `${info.level}: ${info.message}`;
  }
});

export const logger = winston.createLogger({
  transports: [new winston.transports.Console()],
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.colorize(),
    logFormat
  ),
});

const exceptionHandler = new winston.ExceptionHandler(logger);
export const exceptionToMeta = exceptionHandler.getAllInfo.bind(
  exceptionHandler
);

export const logException = (
  message: string,
  error: Error,
  data?: string
): void => {
  const details = exceptionToMeta(error);
  logger.error(message, details === undefined ? details : { details, data });
};
