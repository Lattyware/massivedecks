import { InboundPort, OutboundPort } from "../elm/MassiveDecks";

export interface Voice {
  name: string;
  lang: string;
  default?: boolean;
}

export interface Say {
  voice: string;
  phrase: string;
}

export const register = (
  speechVoices: OutboundPort<Array<Voice>>,
  speechCommands: InboundPort<Say>
) => {
  if ("speechSynthesis" in window) {
    new Speech(speechVoices, speechCommands);
  }
};

class Speech {
  speech: SpeechSynthesis;
  voices: Map<string, SpeechSynthesisVoice>;
  out: OutboundPort<Voice[]>;

  constructor(out: OutboundPort<Array<Voice>>, inbound: InboundPort<Say>) {
    this.speech = window.speechSynthesis;
    this.voices = new Map<string, SpeechSynthesisVoice>();
    this.out = out;
    this.get_voices();

    inbound.subscribe((command) => {
      this.say(command.voice, command.phrase);
    });

    this.speech.addEventListener("voiceschanged", () => this.get_voices());
  }

  get_voices(): void {
    // The slice is a sanity check, Firefox can get pathological with voices.
    const voices = this.speech.getVoices().slice(0, 100);
    this.voices.clear();
    for (const voice of voices) {
      this.voices.set(voice.name, voice);
    }
    this.out.send(
      voices.map((voice) => ({
        name: voice.name,
        lang: voice.lang,
        ...(voice.default ? { default: true } : {}),
      }))
    );
  }

  say(voiceName: string, phrase: string): void {
    const voice = this.voices.get(voiceName);
    if (voice !== undefined) {
      const utterance = new SpeechSynthesisUtterance(phrase);
      utterance.voice = voice;
      this.speech.speak(utterance);
    }
  }
}
