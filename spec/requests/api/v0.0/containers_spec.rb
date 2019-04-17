RSpec.describe("v0.0 - Containers") do
  let(:attributes)        { {"name" => "name", "container_group_id" => container_group.id.to_s, "container_image_id" => container_image.id.to_s, "tenant_id" => tenant.id.to_s} }
  let(:collection_path)   { "/api/v0.0/containers" }
  let(:container_image)   { ContainerImage.create!(:tenant => tenant, :source => source, :source_ref => SecureRandom.uuid) }
  let(:container_group)   { ContainerGroup.create!(:tenant => tenant, :source => source, :source_ref => SecureRandom.uuid, :container_project => container_project, :container_node => container_node) }
  let(:container_node)    { ContainerNode.create!(:tenant => tenant, :source => source, :source_ref => SecureRandom.uuid) }
  let(:container_project) { ContainerProject.create!(:tenant => tenant, :source => source, :source_ref => SecureRandom.uuid) }
  let(:source)            { Source.create!(:name => "name", :source_type => source_type, :tenant => tenant) }
  let(:source_type)       { SourceType.create!(:vendor => "vendor", :product_name => "product_name", :name => "name") }
  let(:tenant)            { Tenant.find_or_create_by!(:name => "default", :external_tenant => "external_tenant_uuid")}

  describe("/api/v0.0/containers") do
    context "get" do
      it "success: empty collection" do
        get(collection_path)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => []
        )
      end

      it "success: non-empty collection" do
        Container.create!(attributes)

        get(collection_path)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => [a_hash_including(attributes)]
        )
      end
    end
  end

  describe("/api/v0.0/containers/:id") do
    def instance_path(id)
      File.join(collection_path, id.to_s)
    end

    context "get" do
      it "success: with a valid id" do
        instance = Container.create!(attributes)

        get(instance_path(instance.id))

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => a_hash_including(attributes.merge("id" => instance.id.to_s))
        )
      end

      it "failure: with an invalid id" do
        instance = Container.create!(attributes)

        missing_id = instance.id * 1000
        get(instance_path(missing_id))

        expect(response).to have_attributes(
          :status => 404,
          :parsed_body => {"errors"=>[{"detail"=>"Record not found", "status"=>404}]}
        )
      end
    end
  end
end
