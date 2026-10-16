#include "RawSampleJsonCodec.h"

#include <gtest/gtest.h>

#include <cstdint>
#include <string>
#include <vector>

using Omniscope::RawSampleJsonCodec::fromJson;
using Omniscope::RawSampleJsonCodec::toJson;

namespace
{

DdsCore::RawSample makeSample(std::vector<uint8_t> bytes)
{
   DdsCore::RawSample sample;
   sample.typeName = "demo::Track";
   sample.bytes = std::move(bytes);
   sample.reliability = "best_effort";
   sample.durability = "transient_local";
   sample.historyDepth = 8;
   return sample;
}

} // namespace

TEST(RawSampleJsonCodec, RoundTripPreservesBytesAndQos)
{
   const auto original = makeSample({0x00, 0x01, 0xab, 0xff});
   const std::string json = toJson(original);
   const auto decoded = fromJson(json);

   ASSERT_TRUE(decoded.has_value());
   EXPECT_EQ(decoded->typeName, original.typeName);
   EXPECT_EQ(decoded->bytes, original.bytes);
   EXPECT_EQ(decoded->reliability, original.reliability);
   EXPECT_EQ(decoded->durability, original.durability);
   EXPECT_EQ(decoded->historyDepth, original.historyDepth);
}

TEST(RawSampleJsonCodec, EmptyPayloadRoundTrips)
{
   const auto original = makeSample({});
   const auto decoded = fromJson(toJson(original));

   ASSERT_TRUE(decoded.has_value());
   EXPECT_TRUE(decoded->bytes.empty());
   EXPECT_EQ(decoded->typeName, original.typeName);
}

TEST(RawSampleJsonCodec, RejectsBadJson)
{
   EXPECT_FALSE(fromJson("").has_value());
   EXPECT_FALSE(fromJson("not-json").has_value());
   EXPECT_FALSE(fromJson("{").has_value());
}

TEST(RawSampleJsonCodec, RejectsMissingOrMalformedRawCdr)
{
   EXPECT_FALSE(fromJson(R"({"type_name":"x"})").has_value());
   EXPECT_FALSE(fromJson(R"({"raw_cdr":"abc"})").has_value()); // odd length
   EXPECT_FALSE(fromJson(R"({"raw_cdr":"zz"})").has_value());  // non-hex
}
