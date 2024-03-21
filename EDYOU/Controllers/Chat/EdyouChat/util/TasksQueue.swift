//
// TasksQueue.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Martin

public class KeyedTasksQueue {
    
    private let dispatcher = QueueDispatcher(label: "TasksQueue");
    private var queues: [BareJID:[Task]] = [:];
    private var inProgress: [BareJID] = [];
    
    func schedule(for key: BareJID, task: @escaping Task) {
        dispatcher.async {
            var queue = self.queues[key] ?? [];
            queue.append(task);
            self.queues[key] = queue;
            self.execute(for: key);
        }
    }
    
    private func execute(for key: BareJID) {
        dispatcher.async {
            guard !self.inProgress.contains(key) else {
                return;
            }
            if var queue = self.queues[key], !queue.isEmpty {
                self.inProgress.append(key);
                let task = queue.removeFirst();
                if queue.isEmpty {
                    self.queues.removeValue(forKey: key);
                } else {
                    self.queues[key] = queue;
                }
                task({
                    self.executed(for: key);
                })
            }
        }
    }
    
    private func executed(for key: BareJID) {
        dispatcher.async {
            self.inProgress = self.inProgress.filter({ (k) -> Bool in
                return k != key;
            });
            self.execute(for: key);
        }
    }
    
    typealias Task = (@escaping ()->Void) -> Void;
}
