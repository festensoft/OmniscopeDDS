#ifndef CYCLONEDDS_CYCLONEDISCOVERYSERVICE_H_
#define CYCLONEDDS_CYCLONEDISCOVERYSERVICE_H_

#include "DdsCore/IDiscoveryService.h"

#include <dds/dds.h>

#include <memory>
#include <optional>
#include <string>
#include <vector>

namespace CycloneDDS
{

/**
 * @brief CycloneDDS implementation of DdsCore::IDiscoveryService.
 *
 * Watches DCPSPublication / DCPSSubscription built-in topics and reports a
 * topic as known while it has active endpoints. Implementation details
 * (BuiltinTopicReader, etc.) are hidden behind pImpl.
 */
class CycloneDiscoveryService : public DdsCore::IDiscoveryService
{
public:
   explicit CycloneDiscoveryService(dds_entity_t participant);
   ~CycloneDiscoveryService() override;

   CycloneDiscoveryService(const CycloneDiscoveryService &) = delete;
   CycloneDiscoveryService &operator=(const CycloneDiscoveryService &) = delete;

   [[nodiscard]] std::vector<std::string> topicNames() const override;
   [[nodiscard]] std::optional<DdsCore::DiscoveredTopic>
   lookup(const std::string &topic) const override;
   void setTopicsChangedCallback(DdsCore::TopicsChangedCallback callback) override;

private:
   struct Impl;
   std::unique_ptr<Impl> _impl;
};

} // namespace CycloneDDS

#endif // CYCLONEDDS_CYCLONEDISCOVERYSERVICE_H_
