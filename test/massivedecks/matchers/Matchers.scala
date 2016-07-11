package massivedecks.matchers

import org.specs2.matcher.{Expectable, MatchResult, Matcher}

object Matchers {

  class UniqueMatcher[E] extends Matcher[Traversable[E]] {
    override def apply[S <: Traversable[E]](t: Expectable[S]): MatchResult[S] =
      result(
        t.value.size == t.value.toSet.size,
        s"${t.description} contains no duplicate values",
        s"${t.description} contains duplicate values",
        t
      )
  }

  def haveNoDuplicateValues[E] = new UniqueMatcher[E]()

}
