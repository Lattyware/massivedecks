const chrome = { cast: { AutoJoinPolicy: { ORIGIN_SCOPED: "ORIGIN_SCOPED" } } };
const cast = {
  framework: {
    CastContextEventType: {
      CAST_STATE_CHANGED: "CAST_STATE_CHANGED",
      SESSION_STATE_CHANGED: "SESSION_STATE_CHANGED",
    },
    CastState: {
      CONNECTED: "CONNECTED",
      NOT_CONNECTED: "NOT_CONNECTED",
      CONNECTING: "CONNECTING",
      NO_DEVICES_AVAILABLE: "NO_DEVICES_AVAILABLE",
    },
    SessionState: {
      SESSION_STARTED: "SESSION_STARTED",
      SESSION_RESUMED: "SESSION_RESUMED",
    },
    CastContext: { getInstance: () => {} },
    CastReceiverContext: { getInstance: () => {} },
    system: { EventType: { ERROR: "ERROR" } },
  },
};
