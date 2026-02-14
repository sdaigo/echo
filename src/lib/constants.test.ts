import { describe, expect, it } from "vitest"
import {
  DEFAULT_PAGE_SIZE,
  MAX_POST_LENGTH,
  MAX_TAGS_PER_POST,
  MAX_TAG_LENGTH,
  SEARCH_DEBOUNCE_MS,
} from "./constants"

describe("constants", () => {
  it("MAX_POST_LENGTH is 280", () => {
    expect(MAX_POST_LENGTH).toBe(280)
  })

  it("MAX_TAG_LENGTH is 50", () => {
    expect(MAX_TAG_LENGTH).toBe(50)
  })

  it("MAX_TAGS_PER_POST is 10", () => {
    expect(MAX_TAGS_PER_POST).toBe(10)
  })

  it("DEFAULT_PAGE_SIZE is 20", () => {
    expect(DEFAULT_PAGE_SIZE).toBe(20)
  })

  it("SEARCH_DEBOUNCE_MS is 300", () => {
    expect(SEARCH_DEBOUNCE_MS).toBe(300)
  })
})
