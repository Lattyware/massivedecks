package massivedecks.stores

import java.util.concurrent.atomic.AtomicLong

import org.hashids.Hashids

/**
  * A generator for game codes.
  */
class GameCodeManager(state: AtomicLong) {
  private val gameCodeEncoder = Hashids.reference("massivedecks", 0, "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")

  def generate() = gameCodeEncoder.encode(state.incrementAndGet())
}
