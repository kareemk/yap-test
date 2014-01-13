describe "Application 'yap-test'" do
  it "creates an index" do
    db = YapDatabase.alloc.initWithPath(path)
    conn = db.newConnection

    txn_proc = proc do |txn|
      txn.removeAllObjectsInAllCollections
      txn.setObject('value', forKey: 'id', inCollection: 'test')
    end
    conn.readWriteWithBlock(txn_proc)

    block = proc do |dict, collection, key, object|
      dict.setObject(object, forKey: 'field')
    end
    setup = YapDatabaseSecondaryIndexSetup.alloc.init
    setup.addColumn('field', withType: YapDatabaseSecondaryIndexTypeText)
    index = YapDatabaseSecondaryIndex.alloc.initWithSetup(setup,
                                                          block: block,
                                                          blockType: YapDatabaseSecondaryIndexBlockTypeWithObject)

    db.registerExtension(index, withName: "idx")

    db.should.not == nil
  end
end

def path
  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0] + "/test.db"
end
