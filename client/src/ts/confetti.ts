import { InboundPort } from "../elm/MassiveDecks";
import * as confetti from "canvas-confetti";

export function register(startConfetti: InboundPort<string>) {
  startConfetti.subscribe(ConfettiManager.start);
}

class ConfettiManager {
  public static async start(id: string) {
    confetti.create(document.getElementById(id) as HTMLCanvasElement, {
      resize: true,
      useWorker: true,
      // @ts-ignore
      disableForReducedMotion: true,
    })({
      origin: { x: 0.5, y: 1 },
      ticks: 400,
      particleCount: 300,
      startVelocity: 90,
      spread: 55,
    });
  }
}
