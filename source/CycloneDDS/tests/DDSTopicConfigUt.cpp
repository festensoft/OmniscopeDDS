#include "CycloneDDS/DDSTopicConfig.h"

#include <gtest/gtest.h>

#include <algorithm>
#include <stdexcept>
#include <string>
#include <vector>

namespace
{

CycloneDDS::TopicEntry makeEntry(const std::string &name)
{
   dds::pub::qos::DataWriterQos writerQos;
   dds::sub::qos::DataReaderQos readerQos;
   return CycloneDDS::TopicEntry{name, writerQos, readerQos};
}

} // namespace

TEST(DDSTopicConfig, RegistersAndLooksUpTopics)
{
   CycloneDDS::DDSTopicConfig config({
      makeEntry("TopicA"),
      makeEntry("TopicB"),
   });

   EXPECT_TRUE(config.hasTopic("TopicA"));
   EXPECT_TRUE(config.hasTopic("TopicB"));
   EXPECT_FALSE(config.hasTopic("Missing"));

   EXPECT_EQ(config.getEntry("TopicA").topicName, "TopicA");
   EXPECT_EQ(config.getEntry("TopicB").topicName, "TopicB");

   const std::vector<std::string> names = config.topicNames();
   EXPECT_EQ(names.size(), 2u);
   EXPECT_NE(std::find(names.begin(), names.end(), "TopicA"), names.end());
   EXPECT_NE(std::find(names.begin(), names.end(), "TopicB"), names.end());
}

TEST(DDSTopicConfig, UnknownTopicThrows)
{
   CycloneDDS::DDSTopicConfig config({makeEntry("OnlyOne")});

   EXPECT_THROW(
      (void)config.getEntry("DoesNotExist"),
      std::out_of_range);
   EXPECT_THROW(
      (void)config.writerQos("DoesNotExist"),
      std::out_of_range);
   EXPECT_THROW(
      (void)config.readerQos("DoesNotExist"),
      std::out_of_range);
}
